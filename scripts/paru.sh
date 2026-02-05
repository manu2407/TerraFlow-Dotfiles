#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# TerraFlow: Paru Repair Module
# ═══════════════════════════════════════════════════════════════════════════════

fix_paru() {
    print_section "Paru Repair (Source Build)"
    
    # Remove conflicts in parallel
    { pkg_installed paru-bin && sudo pacman -Rns --noconfirm paru-bin; } &
    { pkg_installed paru-bin-debug && sudo pacman -Rns --noconfirm paru-bin-debug; } &
    wait

    sudo rm -rf /tmp/paru
    sudo pacman -S --needed --noconfirm base-devel git rust cargo

    git clone --depth=1 https://aur.archlinux.org/paru.git /tmp/paru
    (cd /tmp/paru && makepkg -si --noconfirm)
    
    paru --version && success "Paru repaired" || error "Paru repair failed"
}
