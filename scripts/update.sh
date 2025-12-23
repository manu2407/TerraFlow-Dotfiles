#!/bin/bash

# ==============================================================================
# 🌍 TerraFlow Smart Updater
# ==============================================================================

# --- Configuration ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="/tmp/terraflow-update.log"

# --- Functions ---

log() {
    echo -e "\e[32m[INFO]\e[0m $1"
}

warn() {
    echo -e "\e[33m[WARN]\e[0m $1"
}

error() {
    echo -e "\e[31m[ERROR]\e[0m $1"
}

update_dotfiles() {
    log "Checking TerraFlow configuration..."
    cd "$REPO_ROOT" || { error "Repository root not found"; exit 1; }

    git fetch origin

    if [[ -n $(git status --porcelain) ]]; then
        warn "You have local changes in your config that are not saved."
        echo "Updating now would cause conflicts."

        CONFIRM="n"
        if command -v gum &> /dev/null; then
            if gum confirm "⚠️  DANGER: Discard local changes and force update?"; then
                CONFIRM="y"
            fi
        else
            read -p "⚠️  DANGER: Discard local changes and force update? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                CONFIRM="y"
            fi
        fi

        if [[ "$CONFIRM" == "y" ]]; then
            log "Discarding changes..."
            git reset --hard HEAD
            git pull origin main
            log "Dotfiles updated to latest version."
        else
            echo ":: Update cancelled. Your files are safe."
        fi
    else
        git pull origin main
        log "Dotfiles are up to date."
    fi
}

update_system() {
    log "Updating System Packages..."
    
    # Arch/CachyOS System Update
    if command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm
    fi

    # AUR Helper Update
    if command -v paru &> /dev/null; then
        paru -Syu --noconfirm
    elif command -v yay &> /dev/null; then
        yay -Syu --noconfirm
    fi

    log "System updated."
}

# --- Argument Parsing ---

case "$1" in
    "dot" | "dots")
        update_dotfiles
        ;;
    
    "sys" | "system")
        update_system
        ;;

    "full" | "")
        update_system
        update_dotfiles
        ;;

    *)
        echo "Usage: $(basename "$0") [dot | sys | full]"
        exit 1
        ;;
esac
