#!/bin/bash
# Verify setup with Terra aesthetics

# Colors (Terra Palette)
GREEN='\033[38;2;152;195;121m'  # Moss Green
RED='\033[38;2;224;108;117m'    # Error Red
GREY='\033[38;2;45;49;57m'      # Slate Grey
RESET='\033[0m'

ERRORS=0
TOTAL=0

echo -e "${GREEN}╔═══════════════════════════════════════╗${RESET}"
echo -e "${GREEN}║   TerraFlow Setup Verification       ║${RESET}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${RESET}"
echo ""

check_file() {
    TOTAL=$((TOTAL+1))
    if [ ! -f "$1" ]; then
        echo -e "${RED}✗${RESET} MISSING FILE: $1"
        ERRORS=$((ERRORS+1))
    else
        echo -e "${GREEN}✓${RESET} $1"
    fi
}

check_dir() {
    TOTAL=$((TOTAL+1))
    if [ ! -d "$1" ]; then
        echo -e "${RED}✗${RESET} MISSING DIR: $1"
        ERRORS=$((ERRORS+1))
    else
        echo -e "${GREEN}✓${RESET} $1"
    fi
}

# Check directories
check_dir "configs/hypr"
check_dir "configs/waybar"
check_dir "configs/ags"
check_dir "configs/nwg-drawer"
check_dir "configs/kitty"
check_dir "configs/fish"
check_dir "configs/sddm"
check_dir "assets"
check_dir "scripts"

# Check key files
check_file "install.sh"
check_file "packages.txt"
check_file "configs/hypr/hyprland.conf"
check_file "configs/hypr/colors.conf"
check_file "configs/waybar/config.jsonc"
check_file "configs/starship.toml"
check_file "configs/yazi/yazi.toml"
check_file "configs/lazygit/config.yml"
check_file "configs/mpv/mpv.conf"
check_file "scripts/terra-store"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
if [ $ERRORS -eq 0 ]; then
    PASSED=$((TOTAL - ERRORS))
    echo -e "${GREEN}✓ Verification Successful!${RESET}"
    echo -e "  ${GREEN}${PASSED}/${TOTAL}${RESET} items verified"
else
    PASSED=$((TOTAL - ERRORS))
    echo -e "${RED}✗ Verification Failed!${RESET}"
    echo -e "  ${GREEN}${PASSED}${RESET}/${RED}${TOTAL}${RESET} items verified (${RED}${ERRORS} errors${RESET})"
    exit 1
fi
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
