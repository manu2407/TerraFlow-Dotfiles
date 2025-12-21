#!/bin/bash

# ==============================================================================
# 🌍 TerraFlow Smart Updater
# ==============================================================================

# Get the repository root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT" || { echo "Error: Could not find repository root."; exit 1; }

echo ":: Checking for updates..."
git fetch origin

# 1. CHECK FOR LOCAL CHANGES
# 'git status --porcelain' returns output if there are uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
    
    echo -e "\n\e[33m[WARN]\e[0m You have local changes in your config that are not saved."
    echo "Updating now would cause conflicts."
    
    # 2. THE PROMPT (Using Gum for style, or 'read' for simple bash)
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
        echo ":: Discarding changes..."
        # 3. THE "YES" ACTION (The Nuclear Option)
        git reset --hard HEAD
        git pull origin main
        echo -e "\e[32m[OK]\e[0m System updated to latest version."
    else
        # 4. THE "NO" ACTION
        echo ":: Update cancelled. Your files are safe."
        exit 0
    fi
else
    # NO CHANGES DETECTED - Just pull normally
    git pull origin main
    echo -e "\e[32m[OK]\e[0m System up to date."
fi
