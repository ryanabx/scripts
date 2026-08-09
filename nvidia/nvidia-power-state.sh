#!/bin/sh

# Find the DRM card associated with the NVIDIA GPU
for card in /sys/class/drm/card[0-9]*; do
    pci_id=$(basename "$(readlink -f "$card/device")")

    if lspci -s "$pci_id" | grep -qi 'NVIDIA'; then
        drm_card=$(basename "$card")
        break
    fi
done

if [ -z "$drm_card" ]; then
    echo "Could not find NVIDIA DRM card" >&2
    exit 1
fi

echo "NVIDIA GPU is $drm_card"

POWER_STATE="/sys/class/drm/$drm_card/device/power_state"

while true; do
    cat "$POWER_STATE"
    sleep 1
done
