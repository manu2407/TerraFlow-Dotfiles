#!/bin/bash

# TerraFlow Theme Switcher
# Usage: ./theme-switcher.sh <path/to/image>

IMAGE="$1"
CONF_DIR="$HOME/.config/hypr"
TEMPLATE_DIR="$CONF_DIR/themes/templates"

if [ -z "$IMAGE" ]; then
    echo "Usage: $0 <path/to/image>"
    exit 1
fi

if ! command -v matugen &> /dev/null; then
    echo "Error: 'matugen' is not installed."
    echo "Please install it: cargo install matugen"
    echo "Or via AUR: paru -S matugen-bin"
    exit 1
fi

echo "Setting wallpaper..."
swww img "$IMAGE" --transition-type grow --transition-pos 0.5,0.5 --transition-step 90 --transition-fps 60

echo "Generating colors from $IMAGE..."

# Generate Hyprland Colors
matugen image "$IMAGE" \
    -t "$TEMPLATE_DIR/hyprland-colors.conf" \
    -o "$CONF_DIR/themes/colors.conf"

# Generate Waybar Colors
matugen image "$IMAGE" \
    -t "$TEMPLATE_DIR/waybar-colors.css" \
    -o "$HOME/.config/waybar/colors.css"

echo "Reloading system..."

# Reload Hyprland (Colors)
hyprctl reload

# Reload Waybar (Hot Reload CSS)
# SIGUSR2 reloads the style without restarting the process
killall -SIGUSR2 waybar

echo "Theme applied!"
