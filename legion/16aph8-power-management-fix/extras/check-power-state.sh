#!/bin/sh

# Check the power state of the nvidia dGPU

while true; do cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status; sleep 1; done