#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# TerraFlow Utility Functions
# ═══════════════════════════════════════════════════════════════════════════════

# Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export NC='\033[0m'

print_header() {
    echo -e "\n${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  $1"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}\n"
}

print_section() {
    echo -e "${BLUE}═══ $1 ═══${NC}"
}

success() { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠${NC} $1"; }
error()   { echo -e "${RED}✗${NC} $1"; }

# Fast package check using pacman query
pkg_installed() {
    pacman -Qq "$1" &>/dev/null
}

# Get AUR helper
get_aur_helper() {
    command -v paru &>/dev/null && echo "paru" && return
    command -v yay &>/dev/null && echo "yay" && return
    echo "pacman"
}
