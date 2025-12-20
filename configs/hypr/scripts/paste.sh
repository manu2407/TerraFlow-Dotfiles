#!/bin/bash
# Universal Paste Logic

# 1. Get the class of the active window
WINDOW=$(hyprctl activewindow -j | jq -r ".class")

# 2. Check for Terminal apps (Kitty, Alacritty, WezTerm)
if [[ "$WINDOW" == "kitty" || "$WINDOW" == "Alacritty" ]]; then
    # Terminals need Ctrl+Shift+V
    wtype -M ctrl -M shift -k v -m shift -m ctrl
else
    # Everything else (Browser, Obsidian) needs Ctrl+V
    wtype -M ctrl -k v -m ctrl
fi
