#!/bin/sh

# Expose host binaries
export PATH=$PATH:/run/host/bin
# Expose host libraries (dynamic)
cat <<EOF > /run/flatpak/ld.so.conf.d/runtime-host.conf
/run/host/lib
/run/host/lib64
EOF
# Expose host libraries (linkers, compilers) with pkgconfig
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/run/host/lib/pkgconfig:/run/host/lib64/pkgconfig

"$@"