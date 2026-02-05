#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# TerraFlow: Config Symlink Module
# ═══════════════════════════════════════════════════════════════════════════════

link() {
    local src="$1" dest="$2"
    [[ -e "$dest" && ! -L "$dest" ]] && mv "$dest" "$BACKUP_DIR/"
    [[ -L "$dest" ]] && rm "$dest"
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    echo -e "  ${GREEN}✓${NC} $dest"
}

symlink_configs() {
    local dotfiles_dir="$1"
    local config_dir="$HOME/.config"
    
    print_header "CONFIG SYMLINKER"
    
    export BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Batch symlink - array of source:dest pairs
    local -a links=(
        "hyprland:hypr"
        "quickshell:quickshell"
        "ghostty:ghostty"
        "dunst:dunst"
        "yazi:yazi"
        "btop:btop"
        "mpv:mpv"
        "walker:walker"
        "wlogout:wlogout"
        "nvim:nvim"
    )
    
    for pair in "${links[@]}"; do
        local src="${pair%%:*}" dest="${pair##*:}"
        link "$dotfiles_dir/$src" "$config_dir/$dest"
    done
    
    # Special cases
    link "$dotfiles_dir/starship/starship.toml" "$config_dir/starship.toml"
    link "$dotfiles_dir/hyprlock/hyprlock.conf" "$config_dir/hypr/hyprlock.conf"
    link "$dotfiles_dir/hypridle/hypridle.conf" "$config_dir/hypr/hypridle.conf"
    link "$dotfiles_dir/zsh/.zshrc" "$HOME/.zshrc"
    
    success "Configs linked (backup: $BACKUP_DIR)"
}
