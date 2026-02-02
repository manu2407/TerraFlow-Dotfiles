#!/bin/bash
set -e
echo "Starting paru repair..."

# Clean up
sudo rm -rf /tmp/paru-bin

echo "Installing prerequisites..."
sudo pacman -S --needed --noconfirm base-devel git

echo "Cloning paru-bin..."
cd /tmp
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin

echo "Building and installing paru-bin..."
makepkg -si --noconfirm

echo "Verifying paru installation..."
paru --version

echo "Paru repair complete."
