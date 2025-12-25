# My Arch Linux Dotfiles 🚀

This repository contains my personal configurations for Arch Linux (Kitty, Neovim, Fastfetch, etc.).

## 1. Backup Commands (Run on Old System) 📤

Use these commands to generate backup files before reinstalling.

### Generate Package List
Creates a list of all native packages installed on the system (excludes AUR).
```bash
pacman -Qnqe > pkglist.txt
```

### Backup GNOME Settings
Dumps all current GNOME desktop settings into a file.
```bash
dconf dump / > gnome-settings.ini
```

### Quick Backup (Automated) ⚡
Alternatively, run the backup script to automatically update lists and push changes to GitHub:
```bash
./backup.sh
```


---

## 2. Restore Commands (Run on New System) 📥

Use these commands to set up the new system.

### Link Configurations (Stow)
Symlinks the config folders to the target directory.
```bash
stow kitty mpv fastfetch
```

### Install Packages
Installs packages from the generated list.
```bash
sudo pacman -S --needed - < pkglist.txt
```

### Restore GNOME Settings
Loads the saved settings back into GNOME.
```bash
dconf load / < gnome-settings.ini
```

---

## 3. Quick Setup (Automated) ⚡

Alternatively, run the installation script to do everything automatically:

```bash
sh install.sh
```
