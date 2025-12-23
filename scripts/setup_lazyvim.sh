#!/bin/bash
set -e

# ==============================================================================
# LazyVim Setup Script
# ==============================================================================

log() {
    echo -e "\e[32m[INFO]\e[0m $1"
}

warn() {
    echo -e "\e[33m[WARN]\e[0m $1"
}

# 1. Check for Neovim
if ! command -v nvim &> /dev/null; then
    warn "Neovim is not installed. Attempting to install..."
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm neovim
    else
        echo "Error: Pacman not found. Please install Neovim manually."
        exit 1
    fi
fi

# 2. Backup existing config
NVIM_CONFIG="$HOME/.config/nvim"
if [ -d "$NVIM_CONFIG" ]; then
    # Check if it's already LazyVim (simple check for lazy-lock.json or similar)
    if [ -f "$NVIM_CONFIG/lazy-lock.json" ] && grep -q "LazyVim" "$NVIM_CONFIG/lazy-lock.json"; then
        log "LazyVim appears to be already installed."
        exit 0
    fi

    log "Backing up existing Neovim config to $NVIM_CONFIG.bak"
    rm -rf "$NVIM_CONFIG.bak"
    mv "$NVIM_CONFIG" "$NVIM_CONFIG.bak"
fi

# 3. Install LazyVim Starter
log "Cloning LazyVim starter..."
git clone https://github.com/LazyVim/starter "$NVIM_CONFIG"

# 4. Cleanup git history (optional, but good for user to start fresh)
rm -rf "$NVIM_CONFIG/.git"

log "LazyVim setup complete! Run 'nvim' to start."
