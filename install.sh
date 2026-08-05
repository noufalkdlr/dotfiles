#!/bin/bash

echo "Setting up dotfiles..."

# Ensure stow is present before linking configs
echo "📦 Ensuring stow is installed..."
sudo pacman -S --needed --noconfirm stow

# Create base directories to prevent GNU Stow folder folding
echo "📁 Creating necessary base directories..."
mkdir -p ~/.local ~/.local/share ~/.local/bin ~/.config ~/.config/systemd/user

# Link configurations
./setup-scripts/stow.sh

# Reload user systemd units after stowing dotfiles
echo "Reloading user systemd units... 🔄"
systemctl --user daemon-reload

# Install packages
if [ -f "pkglist.txt" ]; then
  echo "Installing packages from list... 📦"
  sudo pacman -S --needed - <"pkglist.txt"
else
  echo "Error: pkglist.txt not found! ❌"
fi

# Install yay and AUR packages
echo "Setting up yay and AUR packages... 📦"
python3 ./setup-scripts/yay.py

# Install fonts
echo "Setting up fonts... 🔤"
./setup-scripts/setup_fonts.sh

# Enable Services
echo "Enabling Services... 🔌"
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth

echo "Done! All configurations are linked and setup is complete. 🎉"
