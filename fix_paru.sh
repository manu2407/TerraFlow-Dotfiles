#!/bin/bash
set -e
echo "Starting paru repair (Source Build)..."
echo "Note: This will compile paru from source to link against your current system libraries."
echo "This may take a few minutes."

# Clean up
sudo rm -rf /tmp/paru

echo "Installing prerequisites..."
# Ensure we have rust and base-devel
sudo pacman -S --needed --noconfirm base-devel git rust cargo

echo "Cloning paru (source)..."
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru

echo "Building and installing paru..."
# -s: install deps, -i: install package
makepkg -si --noconfirm

echo "Verifying paru installation..."
paru --version

echo "Paru repair complete."
