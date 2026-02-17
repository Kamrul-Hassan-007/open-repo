#!/bin/bash

# Check if bluetooth service is active
if bluetoothctl show | grep -q "Powered: yes"; then
    ICON=""  # Bluetooth On icon
else
    ICON="󰂲"  # Bluetooth Off icon (you can change it)
fi

# Output JSON for waybar
echo "{\"text\": \"$ICON\", \"tooltip\": \"Launch Bluetooth Manager\"}"

