#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# TerraFlow: Terra Apps Installation Module
# ═══════════════════════════════════════════════════════════════════════════════

INSTALL_DIR="/usr/local/bin"

install_terra_apps() {
    local dotfiles_dir="$1"
    
    print_header "TERRA APPS INSTALLER"
    
    # Check cargo
    command -v cargo &>/dev/null || {
        warn "Installing Rust..."
        sudo pacman -S --needed --noconfirm rust cargo
    }
    
    # Build both in parallel
    print_section "Building apps (parallel)"
    (cd "$dotfiles_dir/terra-store" && cargo build --release) &
    local store_pid=$!
    (cd "$dotfiles_dir/terra-shell" && cargo build --release) &
    local shell_pid=$!
    
    wait $store_pid && success "terra-store built" || { error "terra-store build failed"; return 1; }
    wait $shell_pid && success "terra-shell built" || { error "terra-shell build failed"; return 1; }
    
    # Install globally
    print_section "Installing to $INSTALL_DIR"
    sudo install -Dm755 "$dotfiles_dir/terra-store/target/release/terra_store" "$INSTALL_DIR/terra-store"
    sudo install -Dm755 "$dotfiles_dir/terra-shell/target/release/terra_shell" "$INSTALL_DIR/terra-shell"
    
    success "Apps installed: terra-store, terra-shell"
}
