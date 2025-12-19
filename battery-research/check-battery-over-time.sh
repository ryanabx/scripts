#!/bin/sh


REPORT_FILE=energy-report-$(date +"%Y-%m-%d_%H-%M-%S").log
echo "Checking /sys/class/power_supply/BAT1/energy_now over time and saving to '$REPORT_FILE'! Press CTRL+C to quit."

while true; do
    cat /sys/class/power_supply/BAT1/energy_now >> $REPORT_FILE
    sleep 2;
done