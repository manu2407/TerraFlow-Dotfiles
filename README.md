# 🌍 TerraFlow Dotfiles
> **A Modular, Declarative, and Aesthetic Hyprland Environment for Arch Linux & CachyOS.**

![License](https://img.shields.io/badge/License-MIT-blue.svg) ![Distro](https://img.shields.io/badge/Distro-Arch%20%2F%20CachyOS-1793d1) ![WM](https://img.shields.io/badge/WM-Hyprland-00a4a6)

**TerraFlow** is not just a collection of config files; it is an engineered **provisioning system**. It separates logic from data, ensuring a robust, reproducible, and visually stunning environment that treats your theme as a first-class citizen.

---

## ✨ Key Features

* **🧱 Atomic Architecture:** Configs are split into logical modules (Input, Monitors, Rules) rather than monolithic files.
* **🎨 Dynamic Theme Engine:** Powered by **Matugen**. Change your wallpaper, and the entire system (Waybar, Hyprland, Terminals, GTK) updates its color palette instantly.
* **🚀 CachyOS Optimized:** The installer detects CachyOS and automatically swaps generic packages for optimized versions (e.g., `hyprland-cachyos-git`).
* **🛡️ Idempotent Installer:** The installation script is smart. It checks for existing packages, handles conflicts, and can be safely run multiple times without breaking the system.
* **📊 Smart Widgets:** Features **AGS (Aylur's GTK Shell)** for a programmable, JavaScript-based status bar and dashboard.

---

## 🛠️ Installation

### Prerequisites
* A fresh install of **Arch Linux** or **CachyOS**.
* `git` installed (`sudo pacman -S git`).

### Quick Start
Clone the repository and run the installer. The script handles the rest.

```bash
git clone https://github.com/manu2407/TerraFlow-Dotfiles.git
cd TerraFlow-Dotfiles
chmod +x install.sh
./install.sh
```

**What the installer does:**

1. **Detects Distro:** Optimizes packages for CachyOS if present.
2. **Installs AUR Helper:** Sets up `yay` or `paru` automatically.
3. **Parses Package Lists:** Reads from `packages/*.txt` to install Core, UI, and Font packages.
4. **Symlinks Configs:** Uses correct paths to link dotfiles to `~/.config/`.
5. **Generates Theme:** Runs the theme engine on the default wallpaper to initialize colors.

---

## 🎨 Theming Workflow

TerraFlow treats theming as a **State**, not a hardcoded config. Do not edit hex codes manually.

### How to Change the Theme

To change your wallpaper and update the system color scheme:

```bash
# Syntax: theme-switcher.sh <path-to-image>
~/.config/hypr/scripts/theme-switcher.sh ~/Pictures/my-wallpaper.jpg
```

**This command will:**

1. Update the wallpaper using `swww` or `hyprpaper`.
2. Extract colors using `matugen`.
3. Inject variables into `~/.config/hypr/themes/colors.conf`.
4. Reload Hyprland, Waybar, and AGS without a restart.

---

## 📂 Repository Structure

```text
TerraFlow-Dotfiles/
├── configs/             # The actual dotfiles (stowed to ~/.config)
│   ├── hypr/            # Hyprland (Entry point)
│   │   ├── modules/     # Logic (Keybinds, Rules, Monitors)
│   │   └── themes/      # State (Generated colors - Git Ignored)
│   ├── ags/             # Javascript Widgets
│   ├── waybar/          # Fallback Bar
│   └── kitty/           # Terminal
├── packages/            # DATA: Lists of packages to install
│   ├── core.txt         # System essentials
│   └── ui.txt           # Visual components
├── install.sh           # LOGIC: The Master Installer
└── README.md            # You are here
```

---

## ⚙️ Customization

### Adding Packages

Don't edit `install.sh`. Just add the package name to the relevant text file in the `packages/` directory.

* **System Tool:** Add to `packages/core.txt`
* **GUI App:** Add to `packages/extras.txt`

### Monitor Setup

Monitor configurations are isolated to prevent conflicts across devices.
Edit `~/.config/hypr/modules/monitors.conf`:

```ini
# Example
monitor=DP-1, 2560x1440@144, 0x0, 1
monitor=eDP-1, 1920x1080@60, 2560x0, 1
```

---

## 🤝 Contributing

Issues and Pull Requests are welcome!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

**Crafted with ❤️ by manu2407**
