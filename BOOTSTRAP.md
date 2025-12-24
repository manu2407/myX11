# X11 Bootstrap Installer

A clean, reliable bootstrap installer for Arch-based Linux systems with X11.

## Requirements

- **OS**: Arch Linux or Arch-based distribution
- **Display**: X11 (no Wayland support)
- **Shell**: bash
- **Package Manager**: pacman (AUR helper like paru/yay recommended)

## Quick Start

```bash
chmod +x install.sh
./install.sh
```

## What It Does

1. **Detects Package Manager**: Automatically detects and uses paru, yay, or falls back to pacman
2. **Installs Packages**: Reads `package.txt` and installs all missing packages
3. **Enables LightDM**: Configures LightDM as the display manager
4. **Launches RiceInstaller**: Executes the pre-built RiceInstaller for further configuration

## Package List

The installer will install packages from `package.txt`, including:

- **Core utilities**: unzip, blueman
- **Display manager**: LightDM with GTK greeter
- **Shell & dev tools**: fish, neovim, lazygit
- **Containers**: docker, docker-compose, distrobox, lazydocker
- **Browsers**: firefox, chromium, zen-browser
- **Office**: LibreOffice, Obsidian
- **Media**: OBS, qBittorrent, Stremio
- **AI tools**: Google Antigravity

## Features

- ✅ **Idempotent**: Safe to run multiple times
- ✅ **Resilient**: Continues even if individual packages fail
- ✅ **Smart Detection**: Prefers AUR helpers for broader package support
- ✅ **Clean Output**: Color-coded status messages

## Files

- `install.sh` - Main bootstrap installer script
- `package.txt` - Package list (one per line, supports comments)
- `RiceInstaller` - Pre-built configuration tool (from gh0stzk dotfiles)

## Notes

- The installer does NOT modify RiceInstaller or your dotfiles
- X11 is the only supported display system
- AUR packages require an AUR helper (paru/yay)
- This bootstrap runs **before** RiceInstaller to set up base packages
