#!/bin/bash
# in_pack.sh - Install all TerraFlow packages using terra-store
# This script reads package lists and installs them via terra-store

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRA_STORE="$DOTFILES_DIR/terra-store/target/release/terra_store"

echo "╔══════════════════════════════════════════════════════════╗"
echo "║           TERRAFLOW PACKAGE INSTALLER                    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Check if terra-store is built
if [ ! -f "$TERRA_STORE" ]; then
    echo "⚠️  Terra Store not built. Building now..."
    cd "$DOTFILES_DIR/terra-store"
    cargo build --release
    cd "$DOTFILES_DIR"
    echo "✓ Terra Store built successfully"
    echo ""
fi

# Function to install packages from a list file
install_from_list() {
    local list_file="$1"
    local category="$2"
    
    if [ ! -f "$list_file" ]; then
        echo "⚠️  $list_file not found, skipping..."
        return
    fi
    
    echo "═══════════════════════════════════════════════════════"
    echo "📦 Installing: $category"
    echo "═══════════════════════════════════════════════════════"
    
    # Read packages, skip comments and empty lines
    local packages=""
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        packages="$packages $line"
    done < "$list_file"
    
    if [ -n "$packages" ]; then
        echo "Packages:$packages"
        echo ""
        
        # Use terra-store to install (or fallback to paru)
        if command -v paru &> /dev/null; then
            paru -S --needed --noconfirm $packages
        elif command -v yay &> /dev/null; then
            yay -S --needed --noconfirm $packages
        else
            sudo pacman -S --needed --noconfirm $packages
        fi
        
        echo "✓ $category installed"
    fi
    echo ""
}

# Install all package categories
install_from_list "$DOTFILES_DIR/packages/pacman_system.txt" "System Packages"
install_from_list "$DOTFILES_DIR/packages/pacman_tools.txt" "CLI Tools"
install_from_list "$DOTFILES_DIR/packages/pacman_ui.txt" "UI Applications"
install_from_list "$DOTFILES_DIR/packages/fonts.txt" "Fonts"
install_from_list "$DOTFILES_DIR/packages/aur.txt" "AUR Packages"

# Build terra-shell if not already built
echo "═══════════════════════════════════════════════════════"
echo "🔧 Building terra-shell..."
echo "═══════════════════════════════════════════════════════"
if [ ! -f "$DOTFILES_DIR/terra-shell/target/release/terra_shell" ]; then
    cd "$DOTFILES_DIR/terra-shell"
    cargo build --release
    cd "$DOTFILES_DIR"
    echo "✓ Terra Shell built"
else
    echo "✓ Terra Shell already built"
fi
echo ""

echo "══════════════════════════════════════════════════════════════"
echo "✓ All packages installed!"
echo ""
echo "Next steps:"
echo "  1. Run ./install.sh to symlink configs"
echo "  2. Set a wallpaper in theme/wallpapers/"
echo "  3. Log out and into Hyprland"
echo "══════════════════════════════════════════════════════════════"
