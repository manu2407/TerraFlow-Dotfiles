#!/bin/bash

# Reload Hyprland
hyprctl reload

# Reload Waybar
killall waybar
$HOME/.config/hypr/scripts/launch_waybar.sh &

# Reload SwayNC / AGS if applicable
# killall swaync
# swaync-client -R
