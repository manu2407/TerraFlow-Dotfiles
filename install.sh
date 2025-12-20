#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# TerraFlow Master Installer
# ==============================================================================
#
# PHILOSOPHY:
# 1. Determinism: This script either succeeds cleanly or fails early.
# 2. Fail Loudly: Policy violations cause immediate abort, not auto-healing.
# 3. One Owner:  Global resources (fonts, themes) have one explicit provider.
#
# WHY CERTAIN PACKAGES ARE FORBIDDEN:
# thousands of overlapping .ttf files. These conflict with explicit font
# packages (e.g., ttf-opensans) that UI components may depend on.
# The installer refuses to proceed on a system with such packages to prevent
# unpredictable file-conflict errors during installation.
#
# WHY FONTS ARE HANDLED EXPLICITLY:
# Fonts must be installed BEFORE any UI component that depends on them.
# Implicit font installation via dependencies is forbidden because it hides
# ownership and introduces silent conflicts.
#
# WHY THE INSTALLER REFUSES TO AUTO-HEAL:
# Automatically removing packages is dangerous. It may break other software
# the user has installed. The user MUST manually audit and remove the
# conflicting package to acknowledge they understand the consequences.
#
# ==============================================================================

LOG_FILE="install.log"

# --- Forbidden Packages ---
# These packages violate the single-owner policy for fonts and must not be
# present on the system before running this installer.
FORBIDDEN_PKGS=(
    "ttf-ms-fonts"
)

# --- Helper Functions ---

log() {
    echo -e ":: $1"
    echo -e ":: $1" >> "$LOG_FILE"
}

fatal() {
    echo -e "\033[0;31m[FATAL] $1\033[0m"
    echo -e "[FATAL] $1" >> "$LOG_FILE"
    exit 1
}

# --- Preflight Checks ---
# These checks MUST run before ANY package installation.

preflight_check() {
    log "Running Preflight Checks..."

    # 1. Check for forbidden packages
    for pkg in "${FORBIDDEN_PKGS[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            fatal "Forbidden package detected: $pkg

System state violates installer policy.
This package conflicts with explicit font packages required by this dotfile setup.

To proceed, you must manually remove it:
  sudo pacman -Rns $pkg

Then re-run this installer."
        fi
    done

    log "Preflight checks passed."
}

# Safe Install Function
# All package installs MUST go through this function.
install_group() {
    local name="$1"
    shift
    local pkgs=("$@")

    if [ ${#pkgs[@]} -eq 0 ]; then
        log "No packages to install for group: $name"
        return
    fi

    log "Installing Group: $name..."
    yay -S --needed --noconfirm "${pkgs[@]}" || {
        fatal "Failed installing group: $name"
    }
}

# Post-Install Verification
# Ensures no forbidden packages were sneaked in by AUR dependencies.
postflight_check() {
    log "Running Post-Install Verification..."
    for pkg in "${FORBIDDEN_PKGS[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            fatal "Post-install check failed: Forbidden package '$pkg' was installed.

An AUR dependency likely pulled this package in despite the IgnorePkg rule.
This is a critical failure. The system is now in a non-compliant state.

Manual intervention is required:
  1. Remove the package: sudo pacman -Rns $pkg
  2. Investigate which AUR package caused this.
  3. Consider adding explicit conflicts to pacman.conf."
        fi
    done
    log "Post-install verification passed."
}


# ==============================================================================
# EXECUTION
# ==============================================================================

log "Starting TerraFlow Installation..."

# --- 0. Preflight (MUST BE FIRST) ---
preflight_check

# Check Distro
if ! grep -q "Arch" /etc/os-release && ! grep -q "CachyOS" /etc/os-release; then
    fatal "This script is intended for Arch Linux or CachyOS."
fi

# Setup AUR Helper (yay)
if ! command -v yay &> /dev/null; then
    if command -v paru &> /dev/null; then
        log "Using paru as AUR helper."
        # Create an alias for this script's session
        yay() { paru "$@"; }
        export -f yay
    else
        log "No AUR helper found. Installing yay..."
        sudo pacman -S --needed git base-devel --noconfirm
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    fi
fi

# Update System
log "Updating system..."
sudo pacman -Syu --noconfirm || fatal "Failed to update system."


# --- Package Definitions ---

# Core System & Hardware (Order: 1)
CORE_PKGS=(
    "hyprland"
    "xdg-desktop-portal-hyprland"
    "xdg-desktop-portal-gtk"
    "polkit-gnome"
    "hyprlock"
    "hypridle"
    "swww"
    "network-manager-applet"
    "blueman"
    "bluez"
    "bluez-utils"
    "pipewire"
    "pipewire-pulse"
    "pipewire-alsa"
    "wireplumber"
    "pavucontrol"
    "brightnessctl"
    "thunar"
    "thunar-archive-plugin"
    "file-roller"
    "unzip"
    "p7zip"
    "unrar"
    "gvfs"
    "gvfs-mtp"
    "tumbler"
    "ffmpegthumbnailer"
    "wl-clipboard"
    "cliphist"
    "grim"
    "slurp"
    "swappy"
    "fish"
    "starship"
    "neovim"
    "btop"
    "fzf"
    "bat"
    "eza"
    "zoxide"
    "wget"
    "jq"
    "gum"
    "imagemagick"
    "wtype"
)

# Fonts (Order: 2 - MUST be before UI)
# Explicit font ownership. No meta-bundles allowed.
FONT_PKGS=(
    "ttf-inter"
    "ttf-iosevka-nerd"
    "noto-fonts"
    "noto-fonts-cjk"
    "noto-fonts-emoji"
)

# UI Components (Order: 3 - After fonts)
UI_PKGS=(
    "waybar"
    "dunst"
    "sddm"
    "nwg-look"
    "qt5ct"
    "qt6ct"
    "nwg-drawer"
    "aylurs-gtk-shell-git"
    "rofi-wayland"
    "wlogout"
    "kitty"
    "mpv"
    "imv"
)

# Optional Extras (Order: 4)
EXTRA_PKGS=(
    "zen-browser-bin"
    "obsidian"
    "yazi"
    "docker"
    "lazydocker"
    "distrobox"
    "code"
    "lazygit"
    "hyprshot"
)


# --- Installation ---

install_group "Core System" "${CORE_PKGS[@]}"
install_group "Fonts" "${FONT_PKGS[@]}"
install_group "UI Components" "${UI_PKGS[@]}"
install_group "Extras" "${EXTRA_PKGS[@]}"


# --- Post-Install Verification ---
postflight_check


# --- Configuration & Services ---

log "Setting up Docker..."
sudo systemctl enable docker || true
sudo systemctl start docker || true
sudo usermod -aG docker "$USER" || true

log "Linking configurations..."
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"

CONFIGS=("hypr" "waybar" "ags" "nwg-drawer" "kitty" "fish" "sddm" "yazi" "lazygit" "mpv")

for config in "${CONFIGS[@]}"; do
    if [ -d "$CONFIG_DIR/$config" ] && [ ! -L "$CONFIG_DIR/$config" ]; then
        log "Backing up existing $config..."
        mv "$CONFIG_DIR/$config" "$CONFIG_DIR/${config}.bak"
    fi
    ln -sf "$(pwd)/configs/$config" "$CONFIG_DIR/$config"
done

ln -sf "$(pwd)/configs/starship.toml" "$CONFIG_DIR/starship.toml"

mkdir -p "$HOME/.local/bin"
ln -sf "$(pwd)/scripts/terra-store" "$HOME/.local/bin/terra-store"

log "Enabling services..."
sudo systemctl enable sddm || true
sudo systemctl enable bluetooth || true


# --- Assets ---

install_assets() {
    log "Starting Asset Installation..."
    mkdir -p "$HOME/.local/share/fonts"
    mkdir -p "$HOME/.local/share/backgrounds/terra"
    
    WALLPAPER_URL="https://raw.githubusercontent.com/LpCodes/wallpaper/master/Abstract/topography.png"
    wget -q --show-progress -O "$HOME/.local/share/backgrounds/terra/wallpaper.png" "$WALLPAPER_URL" || true

    if command -v magick &> /dev/null; then
        magick "$HOME/.local/share/backgrounds/terra/wallpaper.png" \
        -blur 0x25 \
        "$HOME/.local/share/backgrounds/terra/wallpaper_blur.png" || true
    fi
    
    log "Assets Installed."
}

install_assets


# --- Finalize ---

log "Applying GTK theme..."
nwg-look -a || true

log "Installation Complete! Please reboot."
