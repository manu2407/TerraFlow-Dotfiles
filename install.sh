#!/bin/bash
# install.sh - TerraFlow Dotfiles Symlink Installer

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "╔══════════════════════════════════════════════════════════╗"
echo "║          TERRAFLOW DOTFILES INSTALLER                    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "Dotfiles directory: $DOTFILES_DIR"
echo ""

# Create backup directory
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Function to create symlink with backup
link() {
    local src="$1"
    local dest="$2"
    
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "  ↪ Backing up existing: $dest"
        mv "$dest" "$BACKUP_DIR/"
    elif [ -L "$dest" ]; then
        rm "$dest"
    fi
    
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    echo "  ✓ Linked: $dest"
}

echo "Creating symlinks..."
echo ""

# XDG Config directories
echo "[Hyprland]"
link "$DOTFILES_DIR/hyprland" "$CONFIG_DIR/hypr"

echo "[Quickshell]"
link "$DOTFILES_DIR/quickshell" "$CONFIG_DIR/quickshell"

echo "[Ghostty]"
link "$DOTFILES_DIR/ghostty" "$CONFIG_DIR/ghostty"

echo "[Dunst]"
link "$DOTFILES_DIR/dunst" "$CONFIG_DIR/dunst"

echo "[Yazi]"
link "$DOTFILES_DIR/yazi" "$CONFIG_DIR/yazi"

echo "[Btop]"
link "$DOTFILES_DIR/btop" "$CONFIG_DIR/btop"

echo "[MPV]"
link "$DOTFILES_DIR/mpv" "$CONFIG_DIR/mpv"

echo "[Walker]"
link "$DOTFILES_DIR/walker" "$CONFIG_DIR/walker"

echo "[Wlogout]"
link "$DOTFILES_DIR/wlogout" "$CONFIG_DIR/wlogout"

echo "[Neovim]"
link "$DOTFILES_DIR/nvim" "$CONFIG_DIR/nvim"

echo "[Starship]"
link "$DOTFILES_DIR/starship/starship.toml" "$CONFIG_DIR/starship.toml"

# Hyprlock and Hypridle (inside hypr directory)
echo "[Hyprlock]"
link "$DOTFILES_DIR/hyprlock/hyprlock.conf" "$CONFIG_DIR/hypr/hyprlock.conf"

echo "[Hypridle]"
link "$DOTFILES_DIR/hypridle/hypridle.conf" "$CONFIG_DIR/hypr/hypridle.conf"

# Shell config (home directory)
echo "[Zsh]"
link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "✓ Installation complete!"
echo ""
echo "Backups saved to: $BACKUP_DIR"
echo ""
echo "Next steps:"
echo "  1. Build terra-store:  cd terra-store && cargo build --release"
echo "  2. Build terra-shell:  cd terra-shell && cargo build --release"
echo "  3. Set wallpaper:      swww img theme/wallpapers/your-wallpaper.jpg"
echo "  4. Log out and back in to Hyprland"
echo "══════════════════════════════════════════════════════════════"
 