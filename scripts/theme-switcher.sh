#!/bin/bash
# Reload Hyprland
hyprctl reload
# Reload Waybar
killall waybar
waybar &
# Reload AGS
ags -q
ags &
# Notify
notify-send "TerraFlow" "Theme reloaded!"
