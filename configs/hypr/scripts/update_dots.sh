#!/bin/bash

# Define where your repo lives
REPO_DIR="/home/manu/my self coded programs/new project/TerraFlow-Dotfiles"

echo ":: Checking TerraFlow for updates..."
cd "$REPO_DIR" || { echo "Directory not found!"; exit 1; }

# Fetch latest data without merging yet
git fetch origin

# Check for local changes
if [[ -n $(git status --porcelain) ]]; then
    echo -e "\n\e[33m[WARN]\e[0m You have unsaved local changes."
    
    # Use Gum for the prompt (since you have it installed)
    if command -v gum &> /dev/null; then
        if gum confirm "⚠️  Local changes will be lost. Overwrite & Update?"; then
            echo ":: Force updating..."
            git reset --hard HEAD
            git pull origin main
            echo -e "\n\e[32m[OK]\e[0m Dotfiles updated successfully!"
            
            # Optional: Reload Hyprland to apply changes
            if gum confirm "Reload Hyprland now?"; then
                hyprctl reload
            fi
        else
            echo ":: Update cancelled."
        fi
    else
        # Fallback to read
        read -p "⚠️  Local changes will be lost. Overwrite & Update? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo ":: Force updating..."
            git reset --hard HEAD
            git pull origin main
            echo -e "\n\e[32m[OK]\e[0m Dotfiles updated successfully!"
             hyprctl reload
        else
            echo ":: Update cancelled."
        fi
    fi
else
    # Clean state - just pull
    echo ":: pulling changes..."
    git pull origin main
    echo -e "\n\e[32m[OK]\e[0m Dotfiles are up to date."
fi
