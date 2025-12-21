#!/bin/bash

# Define Paths
HYPR_DIR="$HOME/.config/hypr"
MODULES_DIR="$HYPR_DIR/modules"
WAYBAR_DIR="$HOME/.config/waybar"
KITTY_DIR="$HOME/.config/kitty"
AGS_DIR="$HOME/.config/ags"

# Main Menu Options
options="⚙️  Configs\n🚀  Apps\n📦  Terra Store\n  Keybindings\n  System"

# Rofi Execution
chosen="$(echo -e "$options" | rofi -dmenu -p "Menu")"

case $chosen in
    "⚙️  Configs")
        # Configs Sub-menu
        conf_choice="$(echo -e "Hyprland\nWaybar\nKitty\nAGS" | rofi -dmenu -p "Configs")"
        case $conf_choice in
            "Hyprland")
                # Hyprland Sub-menu
                hypr_choice="$(echo -e "Monitors\nInput\nWindows\nDecoration\nStartup" | rofi -dmenu -p "Hyprland")"
                if [[ -n "$hypr_choice" ]]; then
                    # Convert choice to lowercase for filename (Monitors -> monitors.conf)
                    file="${hypr_choice,,}.conf"
                    kitty -e nvim "$MODULES_DIR/$file"
                fi
                ;;
            "Waybar")
                kitty -e nvim "$WAYBAR_DIR/config.jsonc" "$WAYBAR_DIR/style.css"
                ;;
            "Kitty")
                kitty -e nvim "$KITTY_DIR/kitty.conf"
                ;;
            "AGS")
                kitty -e nvim "$AGS_DIR/config.js"
                ;;
        esac
        ;;
    "🚀  Apps")
        app_choice="$(echo -e "Zen Browser\nFile Manager\nTerminal\nEditor\nFull Launcher" | rofi -dmenu -p "Apps")"
        case $app_choice in
            "Zen Browser") zen-browser ;;
            "File Manager") thunar ;;
            "Terminal") kitty ;;
            "Editor") kitty -e nvim ;;
            "Full Launcher") nwg-drawer ;;
        esac
        ;;
    "  Keybindings")
        kitty -e nvim "$MODULES_DIR/keybinds.conf"
        ;;
    "  System")
        kitty -e nvim "$MODULES_DIR/general.conf"
        ;;
    "📦  Terra Store")
        kitty --class floating -e terra-store
        ;;
esac
