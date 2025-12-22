#!/bin/bash

# Configuration
THRESHOLD_TOP=10
THRESHOLD_BOTTOM=100
INTERVAL=0.1

# State tracking
VISIBLE=1

# Ensure Waybar is running
if ! pgrep -x "waybar" > /dev/null; then
    echo "Waybar is not running. Exiting."
    exit 1
fi

while true; do
    # Get cursor Y position
    Y=$(hyprctl cursorpos | cut -d',' -f2 | tr -d ' ')

    if [ "$Y" -lt "$THRESHOLD_TOP" ] && [ "$VISIBLE" -eq 0 ]; then
        # Mouse is at the top, show Waybar
        pkill -SIGUSR1 waybar
        VISIBLE=1
    elif [ "$Y" -gt "$THRESHOLD_BOTTOM" ] && [ "$VISIBLE" -eq 1 ]; then
        # Mouse moved away, hide Waybar
        pkill -SIGUSR1 waybar
        VISIBLE=0
    fi

    sleep "$INTERVAL"
done
