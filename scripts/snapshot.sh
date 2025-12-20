#!/bin/bash
# Screenshot script
FILE="$HOME/Pictures/Screenshots/$(date +'%Y-%m-%d-%H%M%S.png')"
mkdir -p "$HOME/Pictures/Screenshots"
grim -g "$(slurp)" "$FILE"
notify-send "Screenshot" "Saved to $FILE"
