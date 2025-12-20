# Developer Guide for TerraFlow

This document is intended for developers and power users who want to understand the internal structure of TerraFlow or contribute to the project.

## Repository Structure

The repository is organized as follows:

```
TerraFlow-Dotfiles/
├── assets/             # Wallpapers, fonts, and other binary assets
├── configs/            # Configuration files for all applications
│   ├── hypr/           # Hyprland configs (keybinds, window rules, etc.)
│   ├── waybar/         # Waybar config and style.css
│   ├── ags/            # Aylur's GTK Shell (widgets)
│   ├── fish/           # Fish shell config
│   ├── kitty/          # Kitty terminal config
│   └── ...             # Other configs (yazi, mpv, etc.)
├── scripts/            # Custom scripts
│   ├── terra-store     # The TUI package manager
│   └── ...
├── install.sh          # Master installation script
├── packages.txt        # List of packages to install
└── README.md           # Main documentation
```

## The Installation Process

The `install.sh` script is the heart of the setup. It performs the following operations:

1.  **Distro Check**: Ensures the OS is Arch-based.
2.  **System Update**: Runs `pacman -Syu`.
3.  **Package Installation**: Reads `packages.txt` and installs packages using `yay` or `paru`.
4.  **Asset Setup**: Downloads fonts and wallpapers to `~/.local/share/`.
5.  **Config Linking**: Symlinks directories from `configs/` to `~/.config/`. This allows you to edit files in the repo and see changes immediately.
6.  **Post-Install**: Enables services and updates desktop databases.

## Adding a New Configuration

To add a new application configuration to TerraFlow:

1.  **Create the Config**: Place your configuration files in `configs/<app_name>/`.
2.  **Update Install Script**:
    - Add the application name to the `CONFIGS` array in `install.sh`:
      ```bash
      CONFIGS=("hypr" "waybar" ... "new_app")
      ```
    - If the app requires specific packages, add them to `packages.txt`.

## Customizing Scripts

### Terra Store
The `scripts/terra-store` is a bash script that uses `gum` for the TUI. You can modify the menus, add new categories, or change the installation logic by editing this file.

### Hyprland Scripts
Scripts related to Hyprland (e.g., screenshot, wallpaper changer) are typically found in `configs/hypr/scripts/`.

## Contribution Guidelines

1.  **Fork the Repo**: Create your own fork.
2.  **Branch**: Create a feature branch (e.g., `feature/new-theme`).
3.  **Test**: Ensure your changes work on a fresh install (using a VM is recommended).
4.  **Pull Request**: Submit a PR with a clear description of your changes.

## Style Guide

- **Scripts**: Use `#!/bin/bash` and follow standard shell scripting practices.
- **Configs**: Keep configuration files clean and commented.
- **Markdown**: Use standard Markdown for documentation.
