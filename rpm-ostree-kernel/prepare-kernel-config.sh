#!/usr/bin/env bash
set -euo pipefail

# Copy the configuration of the currently running kernel to the
# shared kernel-builds directory for use inside a toolbox.

die()
{
    echo "ERROR: $*" >&2
    exit 1
}

KERNEL="$(uname -r)"
SOURCE="/usr/lib/modules/$KERNEL/config"
DEST="$HOME/kernel-builds/configs/$KERNEL"

[[ -f "$SOURCE" ]] ||
    die "Kernel config does not exist:

    $SOURCE"

mkdir -p "$(dirname "$DEST")"

cp "$SOURCE" "$DEST"

echo
echo "Copied kernel configuration:"
echo
echo "  Kernel:      $KERNEL"
echo "  Source:      $SOURCE"
echo "  Destination: $DEST"
echo
