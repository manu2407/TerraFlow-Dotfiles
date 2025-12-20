# TerraFlow Walkthrough & User Guide

Welcome to your new **TerraFlow** system! This guide will help you navigate the features, keybindings, and customizations available in this setup.

## 🔑 Essential Keybindings

TerraFlow uses **Hyprland**, a tiling window manager. Navigation is primarily keyboard-driven. The "Mod" key is set to the **Super** (Windows) key.

| Key Combination | Action |
| :--- | :--- |
| `Super + Q` | Open **Kitty** Terminal |
| `Super + C` | Close active window |
| `Super + E` | Open **Yazi** File Manager |
| `Super + Space` | Open **Wofi** App Launcher |
| `Super + D` | Open **NWG-Drawer** (Full App Grid) |
| `Super + F` | Toggle Fullscreen |
| `Super + V` | Toggle Floating Window |
| `Super + L` | Lock Screen |
| `Super + M` | Exit Hyprland (Logout) |

### Window Navigation
- `Super + ←/→/↑/↓`: Move focus to adjacent window
- `Super + Shift + ←/→/↑/↓`: Move active window
- `Super + Mouse Left Click`: Drag window
- `Super + Mouse Right Click`: Resize window

## 🌟 Features Tour

### 1. The Desktop (Hyprland + Waybar)
- **Hyprland**: You'll notice smooth animations when opening and closing windows. Windows automatically tile to fill the screen.
- **Waybar**: The status bar at the top displays:
    - **Workspaces**: Click to switch or scroll to cycle.
    - **Media Player**: Shows currently playing song (Spotify, MPV, etc.).
    - **System Info**: CPU, RAM, Temperature.
    - **Quick Settings**: Network, Bluetooth, Audio, Battery.

### 2. The Terminal (Kitty + Fish)
Open the terminal with `Super + Q`.
- **Shell**: We use **Fish** shell for autosuggestions and syntax highlighting.
- **Prompt**: **Starship** provides a minimal yet informative prompt.
- **Theme**: **Tokyo Night** color scheme is applied consistently.

### 3. File Management (Yazi)
Open Yazi with `Super + E`.
- **Navigation**: Use Vim-like keys (`h`, `j`, `k`, `l`) or arrow keys.
- **Preview**: Automatically previews images, text files, and code.
- **Exit**: Press `q` to quit.

### 4. App Launchers
- **Quick Launch**: `Super + Space` opens **Wofi**, a simple text-based launcher. Type to search.
- **App Grid**: `Super + D` opens **NWG-Drawer**, a full-screen app grid similar to GNOME or Android.

### 5. Terra Store
TerraFlow comes with a custom package manager interface called **Terra Store**.
- **Launch**: Run `terra-store` in your terminal.
- **Features**:
    - Browse and install packages interactively.
    - Search for packages.
    - Update your system.
    - Remove packages.

## 🎨 Customization

### Changing Wallpaper
The wallpaper is located at `~/.local/share/backgrounds/terra/wallpaper.png`.
To change it:
1.  Replace this file with your desired image.
2.  Run the blur generation command (optional, for lockscreen):
    ```bash
    magick ~/.local/share/backgrounds/terra/wallpaper.png -blur 0x25 ~/.local/share/backgrounds/terra/wallpaper_blur.png
    ```
3.  Reload Hyprland (`Super + Shift + R` or logout/login).

### Editing Configs
All configurations are in `~/.config/`.
- **Hyprland**: `~/.config/hypr/hyprland.conf`
- **Waybar**: `~/.config/waybar/config` & `style.css`
- **Kitty**: `~/.config/kitty/kitty.conf`

## 🛠️ Troubleshooting Common Issues

- **Audio not working?**: Click the volume icon in Waybar to open `pavucontrol` (if installed) or check your pipewire settings.
- **Screen flickering?**: If on Nvidia, ensure you have the `nvidia-drm.modeset=1` kernel parameter set.

Enjoy your TerraFlow experience!
