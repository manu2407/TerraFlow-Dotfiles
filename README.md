# 🌊 TerraFlow Dotfiles

> A modular, source-aware dotfiles ecosystem for Hyprland with unified theming

![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=flat-square&logo=wayland&logoColor=white)
![Rust](https://img.shields.io/badge/Rust-000000?style=flat-square&logo=rust&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

---

## ✨ Features

- 🖥️ **Modular Hyprland** - Split config into logical pieces (keybinds, animations, windowrules)
- ⚡ **Terra-Shell** - Rust service daemon powering widgets with real-time system data
- 🔲 **Quickshell Bar** - Beautiful QML widgets connected via IPC
- 🏪 **Terra Store** - TUI package manager with package tracking
- 🎨 **Unified Theming** - CuteCat/Gruvbox theme applied across all apps
- 👻 **Ghostty + Shaders** - GPU terminal with bloom effect

---

## 📦 What's Included

| Component | Description |
|-----------|-------------|
| `hyprland/` | Modular Hyprland config (`conf.d/` structure) |
| `quickshell/` | Status bar & widgets (QML) |
| `terra-shell/` | System service daemon (Rust) |
| `terra-store/` | TUI package manager (Rust) |
| `ghostty/` | Terminal config + 35+ shaders |
| `zsh/` | Shell config with zinit & starship |
| `dunst/` | Notification styling |
| `hyprlock/` | Lock screen |
| `hypridle/` | Idle management |
| `theme/` | Global colors + Hypr-Dots themes |
| `packages/` | Declarative package lists |

---

## 🚀 Quick Start

```bash
# Clone with submodules
git clone --recursive https://github.com/manu2407/TerraFlow-Dotfiles.git
cd TerraFlow-Dotfiles

# Build terra-shell & terra-store
cd terra-shell && cargo build --release && cd ..
cd terra-store && cargo build --release && cd ..

# Install (creates symlinks)
./install.sh

# Add a wallpaper
cp /path/to/wallpaper.jpg theme/wallpapers/
ln -sf $(pwd)/theme/wallpapers/wallpaper.jpg theme/wallpapers/current

# Log out and into Hyprland
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│              QUICKSHELL (QML)               │
│   Bar  │  Workspaces  │  Clock  │  Battery  │
└────────────────┬────────────────────────────┘
                 │ Unix Socket IPC
                 ▼
┌─────────────────────────────────────────────┐
│            TERRA-SHELL (Rust)               │
│  Hyprland IPC │ Audio │ Battery │ Network   │
└─────────────────────────────────────────────┘
```

---

## 🎨 Theme: CuteCat (Gruvbox)

| Element | Color |
|---------|-------|
| Background | `#1d2021` |
| Foreground | `#ebdbb2` |
| Accent | `#fbf1c7` |
| Success | `#b8bb26` |
| Warning | `#fabd2f` |
| Error | `#fb4934` |

Themes from [MrVivekRajan/Hypr-Dots](https://github.com/MrVivekRajan/Hypr-Dots) included as submodules.

---

## ⌨️ Keybindings

| Key | Action |
|-----|--------|
| `Super + Return` | Terminal (Ghostty) |
| `Super + D` | Launcher (Walker) |
| `Super + Q` | Kill window |
| `Super + 1-0` | Workspaces |
| `Super + L` | Lock screen |
| `Super + Shift + E` | Logout menu |
| `Print` | Screenshot |

---

## 📁 Package Lists

Located in `packages/`:

- `pacman_system.txt` - Core system packages
- `pacman_tools.txt` - CLI tools
- `pacman_ui.txt` - GUI applications
- `aur.txt` - AUR packages
- `fonts.txt` - Fonts

Use **Terra Store** TUI to install: `./terra-store/target/release/terra_store`

---

## 🔧 Dependencies

```
hyprland quickshell ghostty zsh starship dunst hyprlock hypridle
swww walker wlogout paru brightnessctl playerctl wpctl
```

---

## 📜 License

MIT License - Feel free to use and modify!

---

<p align="center">
  Made with ❤️ for the Hyprland community
</p>
