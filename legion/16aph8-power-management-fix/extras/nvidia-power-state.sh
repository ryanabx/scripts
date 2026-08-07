#!/bin/sh

# Check the runtime power state of the NVIDIA dGPU.

PCI_ID=$(
    lspci -D |
        awk '/NVIDIA/ && /VGA compatible controller/ { print $1; exit }'
)

if [ -z "$PCI_ID" ]; then
    echo "Error: Could not find an NVIDIA VGA controller."
    exit 1
fi

POWER_STATUS="/sys/bus/pci/devices/$PCI_ID/power/runtime_status"

if [ ! -r "$POWER_STATUS" ]; then
    echo "Error: $POWER_STATUS does not exist or is not readable."
    exit 1
fi

while true; do
    cat "$POWER_STATUS"
    sleep 1
done
