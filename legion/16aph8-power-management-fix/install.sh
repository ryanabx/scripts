#!/bin/sh
# https://github.com/NVIDIA/open-gpu-kernel-modules/issues/905#issuecomment-3360970555

set -e

echo "Installing NVIDIA PM fix files..."

# Install modprobe config
sudo install -Dm0644 /dev/stdin /etc/modprobe.d/999-legion-pm-fix-temp.conf <<'EOF'
options nvidia NVreg_DynamicPowerManagement=0x02
options nvidia NVreg_DynamicPowerManagementVideoMemoryThreshold=0
EOF

# Install udev rule
sudo install -Dm0644 /dev/stdin /etc/udev/rules.d/999-legion-pm-fix-temp.rules <<'EOF'
# Disable runtime PM for NVIDIA VGA/3D controller devices on driver bind
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"

# Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
EOF

# Install systemd service
sudo install -Dm0644 /dev/stdin /etc/systemd/system/999-legion-pm-fix-temp.service <<'EOF'
[Unit]
Description=Enable Nvidia GPU runtime PM
After=graphical.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo auto > /sys/bus/pci/devices/0000:01:00.0/power/control'

[Install]
WantedBy=graphical.target
EOF

# Reload systemd and enable service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable 999-legion-pm-fix-temp.service

echo "A reboot is required to finish installation"
echo "Run: systemctl reboot"