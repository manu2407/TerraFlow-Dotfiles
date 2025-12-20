#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# TerraFlow Master Installer
# ==============================================================================
#
# PHILOSOPHY:
# 1. Authoritative: This script enforces state. It does not ask questions.
# 2. Idempotent: Safe to run multiple times. Skips installed packages.
# 3. Robust: Fails early on errors. Resolves conflicts aggressively.
#
# STRUCTURE:
# 1. Preflight Checks & Conflict Removal
# 2. Core System Utilities
# 3. Fonts (Must be before UI)
# 4. UI / Shell / GTK Components
# 5. Optional Extras
# 6. Configuration & Services
#
# ==============================================================================

LOG_FILE="install.log"

# --- Helper Functions ---

log() {
    echo -e ":: $1"
    echo -e ":: $1" >> "$LOG_FILE"
}

error() {
    echo -e "\033[0;31mERROR: $1\033[0m"
    echo -e "ERROR: $1" >> "$LOG_FILE"
    exit 1
}

# Safe Install Function
# Uses 'yay' with --needed and --noconfirm to ensure idempotency and non-interactivity.
install_group() {
    local name="$1"
    shift
    local pkgs=("$@")

    if [ ${#pkgs[@]} -eq 0 ]; then
        log "No packages to install for group: $name"
        return
    fi

    log "Installing Group: $name..."
    # We use 'yes' pipe to force acceptance of key imports or other prompts that --noconfirm might miss
    # We use --overwrite '*' to bulldoze file conflicts
    yes | yay -S --needed --noconfirm --overwrite '*' "${pkgs[@]}" || {
        error "Failed installing $name"
    }
}

# --- 1. Preflight Checks ---

log "Starting TerraFlow Installation..."

# Check Distro
if ! grep -q "Arch" /etc/os-release && ! grep -q "CachyOS" /etc/os-release; then
    error "This script is intended for Arch Linux or CachyOS."
fi

# Setup AUR Helper (yay)
if ! command -v yay &> /dev/null; then
    if command -v paru &> /dev/null; then
        log "Using paru as AUR helper."
        alias yay='paru'
    else
        log "No AUR helper found. Installing yay..."
        yes | sudo pacman -S --needed git base-devel --noconfirm --overwrite '*'
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    fi
fi

# Conflict Removal Logic
# We aggressively remove known conflicting packages to prevent installation failures.
FORBIDDEN_PKGS=(
    "ttf-google-fonts-typewolf"
    "ttf-ms-fonts"
    "timeshift" # Explicitly removed as per user request
)

log "Checking for forbidden packages..."
for pkg in "${FORBIDDEN_PKGS[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
        log "Removing conflicting package: $pkg"
        sudo pacman -Rns --noconfirm "$pkg" || true
    fi
done

# Update System First
log "Updating system..."
yes | sudo pacman -Syu --noconfirm --overwrite '*' || error "Failed to update system."


# --- 2. Package Definitions ---

# Core System & Hardware
CORE_PKGS=(
    # Window Manager & Core
    "hyprland"
    "xdg-desktop-portal-hyprland"
    "xdg-desktop-portal-gtk"
    "polkit-gnome"
    "hyprlock"
    "hypridle"
    "swww"
    
    # Connectivity & Audio
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
    
    # Files & Archives
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
    
    # Clipboard & Screenshots
    "wl-clipboard"
    "cliphist"
    "grim"
    "slurp"
    "swappy"
    
    # CLI Tools
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

# Fonts (Strict Policy: Single-owner packages only)
FONT_PKGS=(
    "ttf-inter"
    "ttf-iosevka-nerd"
    "noto-fonts"
    "noto-fonts-cjk"
    "noto-fonts-emoji"
)

# UI Components (Must be installed AFTER fonts)
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
    "kitty" # Terminal is UI
    "mpv"
    "imv"
)

# Optional Extras
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


# --- 3. Installation Execution ---

install_group "Core System" "${CORE_PKGS[@]}"
install_group "Fonts" "${FONT_PKGS[@]}"
install_group "UI Components" "${UI_PKGS[@]}"
install_group "Extras" "${EXTRA_PKGS[@]}"


# --- 4. Configuration & Services ---

log "Setting up Docker..."
sudo systemctl enable docker || true
sudo systemctl start docker || true
sudo usermod -aG docker "$USER" || true

log "Linking configurations..."
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"

# List of configs to link
CONFIGS=("hypr" "waybar" "ags" "nwg-drawer" "kitty" "fish" "sddm" "yazi" "lazygit" "mpv")

for config in "${CONFIGS[@]}"; do
    if [ -d "$CONFIG_DIR/$config" ]; then
        # Only backup if it's not already a symlink to our repo
        if [ ! -L "$CONFIG_DIR/$config" ]; then
            log "Backing up existing $config..."
            mv "$CONFIG_DIR/$config" "$CONFIG_DIR/${config}.bak"
        fi
    fi
    # Force link
    ln -sf "$(pwd)/configs/$config" "$CONFIG_DIR/$config"
done

# Link Starship
ln -sf "$(pwd)/configs/starship.toml" "$CONFIG_DIR/starship.toml"

# Link Terra Store
mkdir -p "$HOME/.local/bin"
ln -sf "$(pwd)/scripts/terra-store" "$HOME/.local/bin/terra-store"

log "Enabling services..."
sudo systemctl enable sddm || true
sudo systemctl enable bluetooth || true

# --- 5. Post-Install Assets ---

install_assets() {
    log "Starting Asset Installation..."
    mkdir -p "$HOME/.local/share/fonts"
    mkdir -p "$HOME/.local/share/backgrounds/terra"
    
    # Wallpaper
    WALLPAPER_URL="https://raw.githubusercontent.com/LpCodes/wallpaper/master/Abstract/topography.png"
    wget -q --show-progress -O "$HOME/.local/share/backgrounds/terra/wallpaper.png" "$WALLPAPER_URL" || true

    # Blur generation
    if command -v magick &> /dev/null; then
        magick "$HOME/.local/share/backgrounds/terra/wallpaper.png" \
        -blur 0x25 \
        "$HOME/.local/share/backgrounds/terra/wallpaper_blur.png" || true
    fi
    
    log "Assets Installed."
}

install_assets

# --- 6. Finalize ---

log "Applying GTK theme..."
nwg-look -a || true

log "Installation Complete! Please reboot."
