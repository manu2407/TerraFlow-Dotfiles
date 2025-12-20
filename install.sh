#!/bin/bash

# Project TerraFlow - Master Installation Script

LOG_FILE="install.log"

log() {
    echo -e "$1"
    echo -e "$1" >> "$LOG_FILE"
}

error() {
    echo -e "\033[0;31mERROR: $1\033[0m"
    echo -e "ERROR: $1" >> "$LOG_FILE"
    exit 1
}

log "Starting TerraFlow Installation..."

# 1. Check Distro
if ! grep -q "Arch" /etc/os-release && ! grep -q "CachyOS" /etc/os-release; then
    error "This script is intended for Arch Linux or CachyOS."
fi

# 2. Update System
log "Updating system..."
sudo pacman -Syu --noconfirm || error "Failed to update system."

# 3. Install Packages
log "Installing packages from packages.txt..."

# Check if yay or paru is installed for AUR packages
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
else
    log "No AUR helper found. Installing yay..."
    sudo pacman -S --needed git base-devel --noconfirm
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
    AUR_HELPER="yay"
fi

# Read packages.txt, remove comments and empty lines
if [ -f "packages.txt" ]; then
    # Install packages using the helper
    # We use sed to strip comments (#...) and empty lines
    $AUR_HELPER -S --needed $(sed 's/#.*//' packages.txt) --noconfirm || error "Failed to install packages."
else
    error "packages.txt not found!"
fi

# 3.1 Docker Setup
log "Setting up Docker..."
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# 3.2 VS Code Extensions
log "Installing VS Code extensions..."
code --install-extension PKief.material-icon-theme
code --install-extension enkia.tokyo-night
code --install-extension shengchen.vscode-glassit
code --install-extension usernamehw.errorlens

# 3.3 MPV UOSC Script
log "Installing MPV UOSC script..."
mkdir -p ~/.config/mpv/scripts
curl -L https://github.com/tomasklaen/uosc/releases/latest/download/uosc.zip -o uosc.zip
unzip -o uosc.zip -d ~/.config/mpv/
rm uosc.zip

# 4. Install Assets
install_assets() {
    echo ":: [TerraFlow] Starting Asset Installation..."

    # --- 1. PREPARE DIRECTORIES ---
    mkdir -p "$HOME/.local/share/fonts"
    mkdir -p "$HOME/.local/share/backgrounds/terra"
    mkdir -p "$HOME/Downloads/terra_temp"

    # --- 2. INSTALL FONTS (Direct Download) ---
    echo ":: Downloading Fonts..."
    
    # Iosevka Nerd Font
    wget -q --show-progress -O "$HOME/Downloads/terra_temp/Iosevka.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Iosevka.zip"
    unzip -q -o "$HOME/Downloads/terra_temp/Iosevka.zip" -d "$HOME/.local/share/fonts"
    
    # Inter Font
    wget -q --show-progress -O "$HOME/Downloads/terra_temp/Inter.zip" "https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip"
    unzip -q -o "$HOME/Downloads/terra_temp/Inter.zip" -d "$HOME/Downloads/terra_temp/inter_extracted"
    cp "$HOME/Downloads/terra_temp/inter_extracted/extras/ttf/"*.ttf "$HOME/.local/share/fonts/"

    # Refresh Font Cache
    echo ":: Refreshing Font Cache..."
    fc-cache -fv &> /dev/null

    # --- 3. INSTALL WALLPAPER ---
    echo ":: Downloading Wallpaper..."
    
    # Direct link to the Topographic Dark Wallpaper
    WALLPAPER_URL="https://raw.githubusercontent.com/LpCodes/wallpaper/master/Abstract/topography.png"
    wget -q --show-progress -O "$HOME/.local/share/backgrounds/terra/wallpaper.png" "$WALLPAPER_URL"

    # --- 4. GENERATE LOCKSCREEN (Blur Effect) ---
    # We use ImageMagick to create the blurred version automatically
    echo ":: Generating Blurred Lockscreen..."
    if command -v magick &> /dev/null; then
        magick "$HOME/.local/share/backgrounds/terra/wallpaper.png" \
        -blur 0x25 \
        "$HOME/.local/share/backgrounds/terra/wallpaper_blur.png"
    else
        echo "!! ImageMagick not found. Skipping blur generation."
    fi

    # --- 5. CLEANUP ---
    rm -rf "$HOME/Downloads/terra_temp"
    
    echo ":: [TerraFlow] Assets Installed Successfully."
}

install_assets

# 5. Link Configs
log "Linking configurations..."
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"

# List of configs to link
CONFIGS=("hypr" "waybar" "ags" "nwg-drawer" "kitty" "fish" "sddm" "yazi" "lazygit" "mpv")

for config in "${CONFIGS[@]}"; do
    if [ -d "$CONFIG_DIR/$config" ]; then
        log "Backing up existing $config..."
        mv "$CONFIG_DIR/$config" "$CONFIG_DIR/${config}.bak"
    fi
    ln -sf "$(pwd)/configs/$config" "$CONFIG_DIR/$config"
done

# Link Starship
ln -sf "$(pwd)/configs/starship.toml" "$CONFIG_DIR/starship.toml"

# Link Terra Store
mkdir -p "$HOME/.local/bin"
ln -sf "$(pwd)/scripts/terra-store" "$HOME/.local/bin/terra-store"

# 6. Enable Services
log "Enabling services..."
sudo systemctl enable sddm
sudo systemctl enable bluetooth

# 7. Refresh App Menu
refresh_app_menu() {
    echo ":: [TerraFlow] Forcing App Menu Refresh..."

    # 1. Update the System Database of Apps
    sudo update-desktop-database -q
    
    # 2. Rebuild the Mime Type Cache (File associations)
    sudo update-mime-database /usr/share/mime > /dev/null 2>&1

    # 3. Kill the Launcher Cache
    rm -f ~/.cache/nwg-drawer/data
    pkill wofi || true
    rm -f ~/.cache/rofi/*
    
    echo ":: Apps should now be visible!"
}

refresh_app_menu

# 8. Finalize
log "Applying GTK theme..."
nwg-look -a # Apply settings if possible, or just open it.

log "Installation Complete! Please reboot."
