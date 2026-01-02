#!/bin/sh
# https://github.com/NVIDIA/open-gpu-kernel-modules/issues/905#issuecomment-3360970555

# Install modprobe config
sudo install -Dm0644 data/modprobe-config.conf /etc/modprobe.d/999-legion-pm-fix-temp.conf
# Install udev rule
sudo install -Dm0644 data/udev-rule.rules /etc/udev/rules.d/999-legion-pm-fix-temp.rules
# Install pm auto script
sudo install -Dm0755 data/pm-auto-script.sh /usr/local/lib/999-legion-pm-fix-temp/set-pm-auto.sh
# Install systemd service
sudo install -Dm0644 data/pm-service.service /etc/systemd/system/999-legion-pm-fix-temp.service
# Enable service
sudo systemctl enable 999-legion-pm-fix-temp.service

echo "A reboot is required to finish installation"
echo "Run systemctl reboot"