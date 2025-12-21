#!/bin/bash

# ==============================================================================
# 🌍 TerraFlow Command Center v2.0
# ==============================================================================

# --- Paths & Variables ---
HYPR_DIR="$HOME/.config/hypr"
MODULES_DIR="$HYPR_DIR/modules"
WAYBAR_DIR="$HOME/.config/waybar"
AGS_DIR="$HOME/.config/ags"
THEME_DIR="$HYPR_DIR/themes"

# Editor: Opens in a "Special Workspace" (Layer) to keep your workflow clean
# but TILED inside that layer (Not Floating).
editor() {
    local file="$1"
    # Launch kitty with a specific class for the window rule
    kitty --class terra_settings -e nvim "$file" &
    sleep 0.1; hyprctl dispatch togglespecialworkspace terra_settings
}

# Rofi Command: Added '-i' for CASE INSENSITIVITY
rofi_cmd() {
    rofi -dmenu -i -p "$1" -theme-str 'window {width: 400px;}'
}

# --- Main Logic ---

# 1. Main Menu Options
# Added Network, Media, and Tools categories
options="⚙️  Configs\n📡  Network\n🔊  Media\n🛠️  Tools\n🚀  Apps\n  Keybindings\n  System"

chosen="$(echo -e "$options" | rofi_cmd "TerraFlow")"

case $chosen in
    # ---------------------------------------------------------
    # ⚙️ Configuration Editor
    # ---------------------------------------------------------
    "⚙️  Configs")
        conf="$(echo -e "Hyprland\nWaybar\nAGS\nKitty\nTheme Variables" | rofi_cmd "Configs")"
        case $conf in
            "Hyprland")
                # Scans your modules directory dynamically!
                # This finds ANY file in modules/ and lists it.
                file="$(ls "$MODULES_DIR" | grep ".conf" | sed 's/.conf//' | rofi_cmd "Hyprland Module")"
                [[ -n "$file" ]] && editor "$MODULES_DIR/$file.conf"
                ;;
            "Waybar") editor "$WAYBAR_DIR/config.jsonc" ;;
            "AGS")    editor "$AGS_DIR/config.js" ;;
            "Kitty")  editor "$HOME/.config/kitty/kitty.conf" ;;
            "Theme Variables") editor "$THEME_DIR/theme.conf" ;;
        esac
        ;;

    # ---------------------------------------------------------
    # 📡 Connectivity (New)
    # ---------------------------------------------------------
    "📡  Network")
        net="$(echo -e "WiFi Editor\nBluetooth\nAirplane Mode On\nAirplane Mode Off" | rofi_cmd "Network")"
        case $net in
            "WiFi Editor")    nm-connection-editor & ;;
            "Bluetooth")      blueman-manager & ;;
            "Airplane Mode On")  rfkill block all ;;
            "Airplane Mode Off") rfkill unblock all ;;
        esac
        ;;

    # ---------------------------------------------------------
    # 🔊 Media & Audio (New)
    # ---------------------------------------------------------
    "🔊  Media")
        media="$(echo -e "Volume Mixer\nPlay/Pause\nNext Track\nPrev Track" | rofi_cmd "Media")"
        case $media in
            "Volume Mixer") pavucontrol & ;;
            "Play/Pause")   playerctl play-pause ;;
            "Next Track")   playerctl next ;;
            "Prev Track")   playerctl previous ;;
        esac
        ;;

    # ---------------------------------------------------------
    # 🛠️ Power Tools (New)
    # ---------------------------------------------------------
    "🛠️  Tools")
        tool="$(echo -e "🎨 Color Picker\n📸 Screenshot\n📹 Record Screen\n🧹 Clean Cache" | rofi_cmd "Tools")"
        case $tool in
            "🎨 Color Picker") hyprpicker -a ;; # Copies hex to clipboard
            "📸 Screenshot")   grim -g "$(slurp)" - | wl-copy ;;
            "📹 Record Screen") kooha & ;; # Requires 'kooha' or your preferred recorder
            "🧹 Clean Cache")  rm -rf ~/.cache/thumbnails/* && notify-send "Cache Cleaned" ;;
        esac
        ;;

    # ---------------------------------------------------------
    # 🚀 Quick Apps
    # ---------------------------------------------------------
    "🚀  Apps")
        app="$(echo -e "Browser\nFile Manager\nTerminal" | rofi_cmd "Apps")"
        case $app in
            "Browser")      zen-browser-bin & ;;
            "File Manager") thunar & ;;
            "Terminal")     kitty & ;;
        esac
        ;;

    # ---------------------------------------------------------
    #   Shortcuts
    # ---------------------------------------------------------
    "  Keybindings")
        editor "$MODULES_DIR/keybinds.conf"
        ;;

    # ---------------------------------------------------------
    #   System Control
    # ---------------------------------------------------------
    "  System")
        editor "$MODULES_DIR/general.conf"
        ;;
esac
