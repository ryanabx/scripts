#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only
# SPDX-FileCopyrightText: 2025 Ryan Brue <ryanbrue.dev@gmail.com>

echo "This setup script requires Flathub and Podman. Please follow the instructions for your distribution at https://flathub.org/en/setup"
echo "Special thanks to this GitHub gist: https://gist.github.com/FilBot3/4424d312a87f7b4178722d3b5eb20212"

export XDG_RUNTIME_DIR="/run/user/$UID"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

FLATPAK_ARCH=$(flatpak --default-arch)

echo "Default arch: $FLATPAK_ARCH"

# Look for VSCode, if not installed, look for where the flathub remote is installed
if flatpak list --user | grep -F "com.visualstudio.code" >/dev/null 2>&1; then
    INSTALLATION=user
elif flatpak list --system | grep -F "com.visualstudio.code" >/dev/null 2>&1; then
    INSTALLATION=system
elif flatpak remotes | grep -F "flathub" | grep "user" >/dev/null 2>&1; then 
    INSTALLATION=user
elif flatpak remotes | grep -F "flathub" | grep "system" >/dev/null 2>&1; then
    INSTALLATION=system
fi

echo "Detected Flatpak installation as $INSTALLATION. Installing VScode and the Podman extension..."
flatpak install --assumeyes --$INSTALLATION flathub com.visualstudio.code/$FLATPAK_ARCH/stable com.visualstudio.code.tool.podman/$FLATPAK_ARCH/24.08

echo "Setting flatpak podman override"
flatpak override --$INSTALLATION --filesystem=xdg-run/podman com.visualstudio.code

echo "Enabling the podman socket for the user"
# Check if the service is active
if systemctl --user is-active --quiet podman.socket; then
    echo "User podman socket is running."
else
    echo "User podman socket is not running. Enabling it..."
    systemctl --user enable --now podman.socket
fi

while :; do
    echo "Would you like to create a container for use in vscode [f/y/N]?"
    printf "Enter Y (yes) or N (no) or F (force): "
    read answer

    case "$answer" in
        F|f|Y|y|N|n)
            break
            ;;
        "")
            break
            ;;
        *)
            echo "Invalid input, please enter Y or N."
            ;;
    esac
done

case "$answer" in
    f|F)
        echo "Force creating container 'vscode-development-container'..."
        podman container rm --force vscode-development-container
        podman run --detach --interactive --tty --name vscode-development-container fedora:42
        ;;
    y|Y)
        echo "Creating container 'vscode-development-container'..."
        podman run --detach --interactive --tty --name vscode-development-container fedora:42
        ;;
esac
