# Scripts to build a cloned copy of the Linux kernel as an rpm, and install it for rpm-ostree

Run on host:

```sh
./prepare-kernel-config.sh
```

This creates the current kernel config at `$HOME/kernel-builds/configs/$KERNEL`

Then run in a toolbox from the checked out linux kernel directory:

```sh
./build-kernel.sh
```

Once the kernel is built, the RPMS will be at `$KERNEL_SOURCE/rpmbuild/RPMS/$ARCH`

Install them with:

```sh
sudo rpm-ostree override replace $KERNEL_SOURCE/rpmbuild/RPMS/$ARCH/*
```

Then reboot, and enjoy!
