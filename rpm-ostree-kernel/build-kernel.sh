#!/usr/bin/env bash
set -euo pipefail

# Build an arbitrary Linux kernel git commit as an RPM.
#
# Run this INSIDE a toolbox, from the root of a Linux kernel git repository.
#
# The host must first run prepare-kernel-config.sh.
#
# Usage:
#   ./build-kernel.sh
#
# RPM output:
#   ./rpmbuild/RPMS/<arch>/
#
# Build metadata:
#   ~/kernel-builds/builds/<commit>/

die()
{
    echo "ERROR: $*" >&2
    exit 1
}

log()
{
    echo
    echo "==> $*"
}

# ----------------------------------------------------------------------
# Verify environment
# ----------------------------------------------------------------------

command -v git >/dev/null ||
    die "git is required"

command -v make >/dev/null ||
    die "make is required"

command -v rpm >/dev/null ||
    die "rpm is required"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
    die "Run this from the root of a Linux kernel git repository"

[[ -f Makefile ]] ||
    die "Makefile not found; are you in the kernel source tree?"

# Don't accidentally overwrite local work.
if ! git diff --quiet || ! git diff --cached --quiet; then
    die "Working tree has uncommitted changes"
fi

if [[ -n "$(git status --porcelain --untracked-files=all)" ]]; then
    die "Working tree contains untracked files"
fi

# ----------------------------------------------------------------------
# Prepare kernel configuration
# ----------------------------------------------------------------------

log "Preparing kernel configuration"

HOST_KERNEL="$(uname -r)"
CONFIG_SOURCE="$HOME/kernel-builds/configs/$HOST_KERNEL"

[[ -f "$CONFIG_SOURCE" ]] ||
    die "Host kernel config not found:

    $CONFIG_SOURCE

Run prepare-kernel-config.sh on the host first."

echo "Using host kernel configuration:"
echo "  Kernel: $HOST_KERNEL"
echo "  Config: $CONFIG_SOURCE"

cp "$CONFIG_SOURCE" .config

make olddefconfig

# ----------------------------------------------------------------------
# Determine kernel release
# ----------------------------------------------------------------------

KERNELRELEASE="$(make -s kernelrelease)"

echo "Kernel release: $KERNELRELEASE"

# ----------------------------------------------------------------------
# Build RPM
# ----------------------------------------------------------------------

log "Building kernel RPM"

time make -j"$(nproc)" binrpm-pkg
# time make -j"$(nproc)" rpm-pkg

# ----------------------------------------------------------------------
# Locate generated RPMs
# ----------------------------------------------------------------------

RPM_ARCH="$(rpm --eval '%{_target_cpu}')"
RPM_DIR="./rpmbuild/RPMS/$RPM_ARCH"

[[ -d "$RPM_DIR" ]] ||
    die "RPM output directory was not created:

    $RPM_DIR"

log "Generated RPMs"

mapfile -t RPMS < <(
    find "$RPM_DIR" \
        -maxdepth 1 \
        -type f \
        -name '*.rpm' \
        -print |
    sort
)

[[ "${#RPMS[@]}" -gt 0 ]] ||
    die "No RPMs were generated in:

    $RPM_DIR"

printf '  %s\n' "${RPMS[@]}"

# ----------------------------------------------------------------------
# Identify kernel RPM
# ----------------------------------------------------------------------

KERNEL_RPM=""

for rpm_file in "${RPMS[@]}"; do
    name="$(rpm -qp --qf '%{NAME}' "$rpm_file")"

    if [[ "$name" == "kernel" ]]; then
        KERNEL_RPM="$rpm_file"
        break
    fi
done

[[ -n "$KERNEL_RPM" ]] ||
    die "Could not find a package named 'kernel'"

KERNEL_RPM="$(realpath "$KERNEL_RPM")"

echo
echo "Kernel RPM:"
echo "  $KERNEL_RPM"

# ----------------------------------------------------------------------
# Verify kernel RPM contents
# ----------------------------------------------------------------------

log "Verifying kernel RPM contents"

if ! rpm -qpl "$KERNEL_RPM" |
    grep -Eq '(^|/)(vmlinuz|boot/vmlinuz|usr/lib/modules/.*/vmlinuz)'; then
    die "Kernel RPM does not appear to contain a kernel image"
fi

# ----------------------------------------------------------------------
# Finish
# ----------------------------------------------------------------------

cat <<EOF

======================================================================
Kernel build complete
======================================================================

Commit:
    $COMMIT_FULL

Kernel release:
    $KERNELRELEASE

Kernel RPM:
    $KERNEL_RPM

RPM directory:
    $(realpath "$RPM_DIR")

To stage this kernel on the host:

    ./stage-kernel.sh "$KERNEL_RPM"

That command must be run OUTSIDE the toolbox.

The build script does not modify rpm-ostree and does not reboot.
======================================================================
EOF
