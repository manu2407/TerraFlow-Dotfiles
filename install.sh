#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# TerraFlow Unified Installer
# Modular installer - sources components from scripts/
# ═══════════════════════════════════════════════════════════════════════════════

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source modules
source "$DOTFILES_DIR/scripts/utils.sh"
source "$DOTFILES_DIR/scripts/paru.sh"
source "$DOTFILES_DIR/scripts/packages.sh"
source "$DOTFILES_DIR/scripts/configs.sh"
source "$DOTFILES_DIR/scripts/apps.sh"

# ═══════════════════════════════════════════════════════════════════════════════
# FULL INSTALL
# ═══════════════════════════════════════════════════════════════════════════════

full_install() {
    print_header "TERRAFLOW FULL INSTALLATION"
    install_packages "$DOTFILES_DIR"
    symlink_configs "$DOTFILES_DIR"
    install_terra_apps "$DOTFILES_DIR"
    echo ""
    success "Installation complete! Log out and back into Hyprland."
}

# ═══════════════════════════════════════════════════════════════════════════════
# MENU
# ═══════════════════════════════════════════════════════════════════════════════

show_menu() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════╗
║        ████████╗███████╗██████╗ ██████╗  █████╗          ║
║        ╚══██╔══╝██╔════╝██╔══██╗██╔══██╗██╔══██╗         ║
║           ██║   █████╗  ██████╔╝██████╔╝███████║         ║
║           ██║   ██╔══╝  ██╔══██╗██╔══██╗██╔══██║         ║
║           ██║   ███████╗██║  ██║██║  ██║██║  ██║         ║
║           ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝         ║
║                     F L O W                              ║
║              Unified Installer v2.0                      ║
╚══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "  ${GREEN}1)${NC} Full Install"
    echo -e "  ${BLUE}2)${NC} Packages Only"
    echo -e "  ${BLUE}3)${NC} Configs Only"
    echo -e "  ${BLUE}4)${NC} Terra Apps Only"
    echo -e "  ${YELLOW}5)${NC} Fix Paru"
    echo -e "  ${RED}0)${NC} Exit"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    case "${1:-}" in
        --full)      full_install; exit 0 ;;
        --packages)  install_packages "$DOTFILES_DIR"; exit 0 ;;
        --configs)   symlink_configs "$DOTFILES_DIR"; exit 0 ;;
        --apps)      install_terra_apps "$DOTFILES_DIR"; exit 0 ;;
        --fix-paru)  fix_paru; exit 0 ;;
        -h|--help)
            echo "Usage: ./install.sh [--full|--packages|--configs|--apps|--fix-paru]"
            exit 0 ;;
    esac

    while true; do
        show_menu
        read -p "  Choice [0-5]: " choice
        case $choice in
            1) full_install ;;
            2) install_packages "$DOTFILES_DIR" ;;
            3) symlink_configs "$DOTFILES_DIR" ;;
            4) install_terra_apps "$DOTFILES_DIR" ;;
            5) fix_paru ;;
            0) exit 0 ;;
            *) error "Invalid option" ;;
        esac
        [[ $choice != 0 ]] && read -p "Press Enter..."
    done
}

main "$@"