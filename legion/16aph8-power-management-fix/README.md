# Lenovo Legion 16APH8/16APH9 dGPU D3Cold issue

Based on: https://github.com/NVIDIA/open-gpu-kernel-modules/issues/905#issuecomment-3360970555

This directory has all the files needed to implement the workaround for 16APH8 and 16APH9's dGPU failing to reach D3Cold.

## Usage

> **NOTE:** This requires superuser permissions, to install system files and enable a system service.

```sh
# Must be in the 16aph8-power-management-fix directory!
./install.sh
```

To Uninstall:

```sh
# Must be in the 16aph8-power-management-fix directory!
./uninstall.sh
```

## Verify that the issue is fixed

To verify that the issue is fixed, make sure no apps are using the dGPU:

```sh
./extras/check-apps-using-dgpu.sh
```

then check the power state:

```sh
./extras/check-power-state.sh
```

If you see `suspended` for more than a few lines, the issue should be fixed!

# Disclaimer

This is a **workaround**, and once Nvidia fixes the issue, you will want to uninstall this workaround, so you can use your distribution's default behavior for the nvidia GPU.