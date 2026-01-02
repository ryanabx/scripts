#!/bin/sh
# https://github.com/NVIDIA/open-gpu-kernel-modules/issues/905#issuecomment-3360970555

# Disable service
sudo systemctl disable 999-legion-pm-fix-temp.service
# Remove modprobe config
sudo rm -f /etc/modprobe.d/999-legion-pm-fix-temp.conf
# Remove udev rule
sudo rm -f /etc/udev/rules.d/999-legion-pm-fix-temp.rules
# Remove pm auto script
sudo rm -rf /var/lib/999-legion-pm-fix-temp/
# Remove systemd service
sudo rm -f /etc/systemd/system/999-legion-pm-fix-temp.service

echo "A reboot is required to finish uninstall"
echo "Run systemctl reboot"