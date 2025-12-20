#!/bin/bash
# Script to launch Waybar and ensure it restarts correctly

# Kill existing instances
killall waybar
pkill waybar

# Wait a moment for cleanup
sleep 0.5

# Start Waybar and log output
waybar > /tmp/waybar.log 2>&1 &
