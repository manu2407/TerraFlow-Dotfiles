#!/bin/bash

# Define Paths
CONFIG_DIR="$HOME/.config/hypr/modules"

# Main Menu Options
# Use Icons (Nerd Fonts) if possible for "Setup", "Keybindings", etc.
options="  Setup\n  Keybindings\n  System\n📦 Terra Store"

# Rofi Execution
chosen="$(echo -e "$options" | rofi -dmenu -p "Menu")"

case $chosen in
    "  Setup")
        # Sub-menu logic
        setup_choice="$(echo -e "Monitors\nInput\nWindows" | rofi -dmenu -p "Setup")"
        if [[ $setup_choice == "Monitors" ]]; then
             # LAUNCH COMMAND - Note the --class flag
             kitty --class floating -e nvim "$CONFIG_DIR/monitors.conf"
        elif [[ $setup_choice == "Input" ]]; then
             kitty --class floating -e nvim "$CONFIG_DIR/input.conf"
        elif [[ $setup_choice == "Windows" ]]; then
             kitty --class floating -e nvim "$CONFIG_DIR/windows.conf"
        fi
        ;;
    "  Keybindings")
        kitty --class floating -e nvim "$CONFIG_DIR/keybinds.conf"
        ;;
    "  System")
        kitty --class floating -e nvim "$CONFIG_DIR/general.conf"
        ;;
    "📦 Terra Store")
        kitty --class floating -e terra-store
        ;;
esac
