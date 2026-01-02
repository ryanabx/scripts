# A few Lenovo Legion tools

> **NOTE:** All of these are tested on my Lenovo Legion 16APH8 with a 7640HS and RTX 4060

# How to use scripts

## Legion Custom Control

This script is used to set/get power limits (SPPT, FPPT, SPL) in a pinch. You must be plugged into AC to use `custom` mode.

## Legion screen setting commands

KDE Plasma has the ability to run a script when a charger is connected and disconnected from a laptop. Using this, we can automatically set 60hz when unplugging, and 165hz when plugged in.

You can find these settings in `Power Management`

## 16aph8-power-management-fix

There is an issue with 16APH8 and 16APH9 that doesn't allow the Nvidia dGPU to enter D3Cold state.

https://github.com/NVIDIA/open-gpu-kernel-modules/issues/905

Running the `install.sh` script while in the script directory will install a temporary workaround that should fix the issue.

Run the `uninstall.sh` script to remove it. Make sure to inspect the script and verify everything looks right to you! The script is based on [this workaround](https://github.com/NVIDIA/open-gpu-kernel-modules/issues/905#issuecomment-3360970555)