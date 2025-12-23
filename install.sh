#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# TerraFlow Master Installer (Level 2: Categorized Loader)
# ==============================================================================

LOG_FILE="install.log"
PACKAGES_DIR="packages"

# --- Path Resolution (Critical Fix) ---
# Get the absolute path of the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

# --- Helper Functions ---

log() {
    echo -e "\e[32m[INFO]\e[0m $1"
    echo -e "[INFO] $1" >> "$LOG_FILE"
}

warn() {
    echo -e "\e[33m[WARN]\e[0m $1"
    echo -e "[WARN] $1" >> "$LOG_FILE"
}

fatal() {
    echo -e "\e[31m[FATAL]\e[0m $1"
    echo -e "[FATAL] $1" >> "$LOG_FILE"
    exit 1
}

# Idempotent Install Function
install_package() {
    local pkg="$1"

    # Check if installed via pacman
    if pacman -Qi "$pkg" &> /dev/null; then
        log "Skipping $pkg (already installed)"
        return 0
    fi

    log "Installing $pkg..."
    # Try pacman first, then AUR helper
    if sudo pacman -S --noconfirm --needed "$pkg" 2>/dev/null; then
        log "Installed $pkg via pacman"
    else
        log "Package not found in repos, trying AUR..."
        yay -S --noconfirm --needed "$pkg" || fatal "Failed to install $pkg"
    fi
}

# --- Preflight Checks ---

log "Starting TerraFlow Installation..."

# --- Sudo Keep-Alive ---
# Ask for sudo upfront
sudo -v
# Keep sudo alive in the background while the script runs
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Check Distro
if ! grep -q "Arch" /etc/os-release && ! grep -q "CachyOS" /etc/os-release; then
    fatal "This script is intended for Arch Linux or CachyOS."
fi

# Setup AUR Helper
if ! command -v yay &> /dev/null; then
    if command -v paru &> /dev/null; then
        log "Using paru as AUR helper."
        yay() { paru "$@"; }
        export -f yay
    else
        log "Installing yay..."
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

# --- Package Installation ---

# Check for CachyOS
IS_CACHYOS=false
if grep -q "CachyOS" /etc/os-release; then
    IS_CACHYOS=true
    log "CachyOS detected! Optimizations enabled."
fi

# Function to load and install packages from a file
install_from_file() {
    local file="$1"
    local category_name=$(basename "$file" .txt)
    
    if [ ! -f "$file" ]; then
        warn "Package file not found: $file"
        return
    fi

    log "Processing category: $category_name"
    
    # Read file line by line
    while IFS= read -r pkg || [ -n "$pkg" ]; do
        # Skip empty lines and comments
        [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
        
        # CachyOS Swap Logic
        if [ "$IS_CACHYOS" = true ] && [ "$pkg" = "hyprland" ]; then
            pkg="hyprland-cachyos-git"
            log "Swapped hyprland for hyprland-cachyos-git"
        fi

        install_package "$pkg"
    done < "$file"
}

# Install Categories
install_from_file "$REPO_ROOT/$PACKAGES_DIR/core.txt"
install_from_file "$REPO_ROOT/$PACKAGES_DIR/fonts.txt"
install_from_file "$REPO_ROOT/$PACKAGES_DIR/ui.txt"
install_from_file "$REPO_ROOT/$PACKAGES_DIR/extras.txt"

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
    ln -sf "$REPO_ROOT/configs/$config" "$CONFIG_DIR/$config"
done

ln -sf "$REPO_ROOT/configs/starship.toml" "$CONFIG_DIR/starship.toml"

mkdir -p "$HOME/.local/bin"
ln -sf "$REPO_ROOT/scripts/terra-store" "$HOME/.local/bin/terra-store"

log "Enabling services..."
sudo systemctl enable sddm || true
sudo systemctl enable bluetooth || true

# --- Assets ---

log "Installing Assets..."
mkdir -p "$HOME/.local/share/fonts"
mkdir -p "$HOME/.local/share/backgrounds/terra"

WALLPAPER_URL="https://raw.githubusercontent.com/LpCodes/wallpaper/master/Abstract/topography.png"
if [ ! -f "$HOME/.local/share/backgrounds/terra/wallpaper.png" ]; then
    wget -q --show-progress -O "$HOME/.local/share/backgrounds/terra/wallpaper.png" "$WALLPAPER_URL" || true
fi

if command -v magick &> /dev/null; then
    if [ ! -f "$HOME/.local/share/backgrounds/terra/wallpaper_blur.png" ]; then
        magick "$HOME/.local/share/backgrounds/terra/wallpaper.png" \
        -blur 0x25 \
        "$HOME/.local/share/backgrounds/terra/wallpaper_blur.png" || true
    fi
fi

# --- Finalize ---

log "Generating initial theme..."
if [ -f "$REPO_ROOT/configs/hypr/scripts/theme-switcher.sh" ]; then
    chmod +x "$REPO_ROOT/configs/hypr/scripts/theme-switcher.sh"
    # Run against the downloaded wallpaper
    "$REPO_ROOT/configs/hypr/scripts/theme-switcher.sh" "$HOME/.local/share/backgrounds/terra/wallpaper.png"
else
    warn "Theme switcher script not found!"
fi

log "Applying GTK theme..."
nwg-look -a || true

log "Setting up LazyVim..."
"$REPO_ROOT/scripts/setup_lazyvim.sh" || warn "LazyVim setup failed."

log "Installation Complete! Please reboot."
