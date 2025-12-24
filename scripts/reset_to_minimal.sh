#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# TerraFlow System Reset & Factory Restore Tool
# ==============================================================================
# WARNING: This script contains destructive operations.
# It is designed to help reset the system to a minimal state or "Factory Reset".
# ==============================================================================

LOG_FILE="reset.log"
BACKUP_DIR="$HOME/terraflow_backup_$(date +%Y%m%d_%H%M%S)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Helper Functions ---

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
    echo "[INFO] $1" >> "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    echo "[WARN] $1" >> "$LOG_FILE"
}

fatal() {
    echo -e "${RED}[FATAL]${NC} $1"
    echo "[FATAL] $1" >> "$LOG_FILE"
    exit 1
}

confirm() {
    read -p "$1 [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Operation cancelled by user."
        exit 0
    fi
}

# --- Core Logic ---

backup_configs() {
    log "Backing up ~/.config to $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    if [ -d "$HOME/.config" ]; then
        cp -r "$HOME/.config" "$BACKUP_DIR/"
    fi
    log "Backup complete."
}

uninstall_terraflow() {
    log "Uninstalling TerraFlow packages..."
    
    # Collect packages from files
    local packages_to_remove=()
    for file in "$REPO_ROOT/packages/"*.txt; do
        [ -e "$file" ] || continue
        while IFS= read -r pkg || [ -n "$pkg" ]; do
            [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
            packages_to_remove+=("$pkg")
        done < "$file"
    done

    if [ ${#packages_to_remove[@]} -eq 0 ]; then
        warn "No packages found to remove."
        return
    fi

    echo -e "${YELLOW}The following packages will be removed:${NC}"
    printf '%s\n' "${packages_to_remove[@]}" | sort | uniq
    
    confirm "Are you sure you want to remove these packages?"

    # Remove packages
    sudo pacman -Rns --noconfirm "${packages_to_remove[@]}" || warn "Some packages could not be removed (dependencies?)"
    
    log "TerraFlow packages removed."
}

factory_reset() {
    echo -e "${RED}!!! DANGER: FACTORY RESET MODE !!!${NC}"
    echo -e "${RED}This will remove ALL packages except for a critical allowlist.${NC}"
    echo -e "${RED}This is intended to revert to a minimal Arch/CachyOS install.${NC}"
    echo
    
    # Critical Allowlist (Regex patterns)
    # Keeps: base, linux, firmware, sudo, git, network tools, editors, filesystems, bootloaders
    local allowlist="^(base|base-devel|linux|linux-firmware|linux-headers|sudo|git|vim|nano|networkmanager|dhcpcd|iwd|openssh|grub|efibootmgr|os-prober|intel-ucode|amd-ucode|btrfs-progs|e2fsprogs|dosfstools|man-db|man-pages|texinfo|pacman|pacman-contrib|yay|paru)$"

    # Get all explicitly installed packages
    local all_pkgs
    all_pkgs=$(pacman -Qqe)

    # Filter packages
    local pkgs_to_nuke=()
    while IFS= read -r pkg; do
        if [[ ! "$pkg" =~ $allowlist ]]; then
            pkgs_to_nuke+=("$pkg")
        fi
    done <<< "$all_pkgs"

    if [ ${#pkgs_to_nuke[@]} -eq 0 ]; then
        log "System is already minimal. No packages to remove."
        return
    fi

    echo -e "${YELLOW}The following packages will be PERMANENTLY REMOVED:${NC}"
    printf '%s\n' "${pkgs_to_nuke[@]}"
    echo
    echo -e "${RED}Total packages to remove: ${#pkgs_to_nuke[@]}${NC}"
    
    echo -e "Type ${RED}AGREE${NC} to proceed with DESTRUCTION:"
    read -r user_input
    if [ "$user_input" != "AGREE" ]; then
        log "Factory reset aborted."
        return
    fi

    # Backup first
    backup_configs

    # Nuke
    log "Starting Factory Reset..."
    # We use a loop or batch to avoid command line length limits if list is huge, 
    # but pacman usually handles large lists okay.
    sudo pacman -Rns --noconfirm "${pkgs_to_nuke[@]}" || warn "Some packages failed to uninstall."

    # Wipe Configs
    log "Wiping ~/.config..."
    rm -rf "$HOME/.config"
    mkdir -p "$HOME/.config"

    log "Factory Reset Complete."
}

set_minimal_mode() {
    log "Switching to Minimal Mode (Text-Only)..."
    echo -e "${YELLOW}This will disable the graphical login manager (SDDM/GDM) and set the default target to multi-user.${NC}"
    confirm "Proceed?"

    sudo systemctl set-default multi-user.target
    log "Default target set to multi-user.target."
    
    if systemctl is-active --quiet sddm; then
        log "Stopping SDDM..."
        sudo systemctl disable --now sddm || true
    fi
    
    log "Minimal mode enabled. Reboot to take full effect."
}

# --- Main Menu ---

echo -e "${YELLOW}TerraFlow Reset Tool${NC}"
echo "1) Uninstall TerraFlow Packages (Safe)"
echo "2) Switch to Minimal Mode (Text-Only)"
echo "3) Factory Reset (Distro Nuke - DANGEROUS)"
echo "4) Exit"

read -p "Select an option: " choice

case "$choice" in
    1)
        uninstall_terraflow
        ;;
    2)
        set_minimal_mode
        ;;
    3)
        factory_reset
        set_minimal_mode
        ;;
    4)
        exit 0
        ;;
    *)
        echo "Invalid option."
        exit 1
        ;;
esac
