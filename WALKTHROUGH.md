# TerraFlow Modular Upgrade Walkthrough

I have successfully upgraded your TerraFlow dotfiles to a "Gold Standard" modular architecture.

## 1. Modular Hyprland Configuration

Your `hyprland.conf` is now a clean entry point that sources atomic modules.

**Directory Structure:**
```text
~/.config/hypr/
├── hyprland.conf           # Entry point
├── modules/                # Atomic configurations
│   ├── monitors.conf       # Monitor settings
│   ├── input.conf          # Keyboard/Mouse
│   ├── keybinds.conf       # Keybindings
│   ├── windows.conf        # Window rules
│   ├── decoration.conf     # Visuals (blur, shadow)
│   ├── general.conf        # Layout, gaps, borders
│   └── startup.conf        # Autostart commands
└── themes/                 # Theme configurations
    ├── colors.conf         # Generated colors
    └── theme.conf          # Static theme settings
```

## 2. Dynamic Theme Engine & Material You Waybar

I have implemented a theme engine using `matugen` and a **Material You** design for Waybar.

**How to use:**
```bash
~/.config/hypr/scripts/theme-switcher.sh /path/to/your/wallpaper.jpg
```

**What happens:**
1.  **Hyprland**: Updates border colors and variables.
2.  **Waybar**: Updates bar colors (background, text, accent) to match the wallpaper.
    -   **Design**: Features **Compact Material** "pill" modules, dynamic pastel colors, and a slim 32px height.
3.  **System**: Reloads Hyprland and Waybar automatically.

## 3. AGS (Aylur's GTK Shell) Integration

I have restructured your AGS config into a modular widget system.

**New Structure:**
```text
~/.config/ags/
├── config.js           # Imports widgets
├── widget/
│   ├── Bar.js          # Status Bar (Workspaces, Clock)
│   └── Dashboard.js    # Control Center (Volume, Net, Media)
```

    └── Dashboard.js    # Control Center (Volume, Net, Media)
```

## 4. Command Center v2.0

I have upgraded the dashboard to a full Command Center.

**Keybinding:** `SUPER + S`

**Features:**
-   **Dynamic Configs:** Automatically finds and lists Hyprland modules.
-   **Special Workspace:** Editors open in a dedicated, tiled "Special Workspace" layer.
-   **Tools:** Includes Network, Media, Color Picker, and Screenshot tools.
-   **Terra Store v2.0:** Integrated access to the custom package manager.

## 5. Terra Store v2.0

A custom TUI package manager wrapper for `pacman` and `paru`.

**Features:**
-   **Pre-Authentication:** Handles sudo upfront for uninterrupted browsing.
-   **Silent Install:** Fast, auto-confirm installations.
-   **Visuals:** Clean, theme-aware interface using `gum`.

## 6. Smart Updater

I have included a "Safety Valve" updater script to handle git conflicts.

**How to use:**
```bash
./scripts/update.sh
```

**Logic:**
1.  **Checks for local changes.**
2.  **If clean:** Updates automatically.
3.  **If dirty:** Prompts you to **overwrite** local changes or **cancel**.

## 7. Natural Language Commands

I have added a smart `update` function to your shell.

**Commands:**
-   `update full`: Runs a full system upgrade (`paru -Syu` or `yay -Syu`).
-   `update dot`: Updates your dotfiles with the "Smart Safety Check".

## 8. Categorized Installation System (Level 2)

I have refactored the installation system to be **idempotent** and **modular**.

**New Structure:**
```text
TerraFlow/
├── install.sh              # The main script (Logic)
└── packages/               # Package Lists (Data)
    ├── core.txt            # Core system packages
    ├── fonts.txt           # Fonts
    ├── ui.txt              # UI components
    └── extras.txt          # Extra apps
```

**Features:**
-   **Idempotent**: Checks if a package is installed before trying to install it. Safe to run multiple times.
-   **CachyOS Aware**: Automatically swaps `hyprland` for `hyprland-cachyos-git` if running on CachyOS.
-   **AUR Support**: Automatically installs `yay` if missing and uses it for AUR packages.

## Verification

To verify everything is working:
1.  **Reload Hyprland**: `hyprctl reload` (should happen automatically).
2.  **Test Theme Switcher**: Run the script with an image.
3.  **Check AGS**: Ensure the bar and dashboard load.
4.  **Test Installer**: Run `./install.sh` (it should skip already installed packages).
