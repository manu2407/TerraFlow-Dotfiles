#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# TerraFlow: Package Installation Module
# ═══════════════════════════════════════════════════════════════════════════════

# Fast package list parser - strips comments and empty lines
parse_pkg_list() {
    grep -v '^#' "$1" 2>/dev/null | grep -v '^$' | tr '\n' ' '
}

ensure_paru() {
    command -v paru &>/dev/null && return 0
    warn "Installing paru-bin..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone --depth=1 https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
    (cd /tmp/paru-bin && makepkg -si --noconfirm)
    success "paru installed"
}

install_packages() {
    local dotfiles_dir="$1"
    local pkg_dir="$dotfiles_dir/packages"
    
    print_header "PACKAGE INSTALLER"
    ensure_paru
    
    local helper=$(get_aur_helper)
    local all_packages=""
    
    # Collect all packages in one pass
    for list in pacman_system.txt pacman_tools.txt pacman_ui.txt fonts.txt aur.txt; do
        [[ -f "$pkg_dir/$list" ]] && all_packages+=" $(parse_pkg_list "$pkg_dir/$list")"
    done
    
    if [[ -n "$all_packages" ]]; then
        print_section "Installing all packages"
        if [[ "$helper" == "pacman" ]]; then
            sudo pacman -S --needed --noconfirm $all_packages
        else
            $helper -S --needed --noconfirm $all_packages
        fi
        success "All packages installed"
    fi
}
