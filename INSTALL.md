# Installation Guide for TerraFlow

This guide provides detailed instructions on how to install and set up the TerraFlow dotfiles on your system.

## Prerequisites

Before you begin, ensure you have the following:

- **Operating System**: A fresh installation of **Arch Linux** or **CachyOS**.
- **Internet Connection**: Required to download packages and assets.
- **Git**: To clone the repository (usually pre-installed, but good to check).

## Step-by-Step Installation

### 1. Clone the Repository

Open your terminal and clone the TerraFlow repository to your home directory or a preferred location.

```bash
git clone https://github.com/manu2407/TerraFlow-Dotfiles.git
cd TerraFlow-Dotfiles
```

### 2. Run the Installation Script

The `install.sh` script automates the entire process. It will update your system, install necessary packages, set up configurations, and download assets.

Make the script executable and run it:

```bash
chmod +x install.sh
./install.sh
```

**What the script does:**
1.  **Checks Distro**: Verifies you are running Arch or CachyOS.
2.  **Updates System**: Runs `pacman -Syu`.
3.  **Installs Packages**: Installs all packages listed in `packages.txt` using `yay` or `paru`.
4.  **Sets up Docker**: Enables Docker service and adds your user to the docker group.
5.  **Configures VS Code**: Installs recommended extensions.
6.  **Installs Assets**: Downloads fonts (Iosevka, Inter) and the default wallpaper.
7.  **Links Configs**: Symlinks configuration files from `configs/` to `~/.config/`.
8.  **Enables Services**: Enables SDDM and Bluetooth.
9.  **Refreshes App Menu**: Updates desktop database and caches.

### 3. Post-Installation

Once the script completes, you will see a "Installation Complete!" message.

1.  **Reboot your system**:
    ```bash
    reboot
    ```
2.  **Select Hyprland**: At the login screen (SDDM), ensure **Hyprland** is selected as your session.
3.  **Login**: Enter your password and enjoy TerraFlow!

## Troubleshooting

### "Command not found: yay"
The script attempts to install `yay` if no AUR helper is found. If this fails, you can manually install it:
```bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### "Failed to install packages"
If the script fails during package installation, check your internet connection and try running the update command manually:
```bash
yay -Syu
```
Then run the script again. It is safe to re-run `install.sh`.

### Graphics Issues
If you are using NVIDIA, ensure you have the correct drivers installed. CachyOS usually handles this well, but you may need to check the [Hyprland Nvidia Guide](https://wiki.hyprland.org/Nvidia/).

## Customization

After installation, you can customize your experience by editing the files in `~/.config/`. Since these are symlinked to your cloned repository, you can edit them directly in the `TerraFlow-Dotfiles/configs` directory and commit your changes to your own fork.
