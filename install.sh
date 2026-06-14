#!/bin/bash

echo "Setting up dotfiles..."

# Create base directories to prevent GNU Stow folder folding
echo "📁 Creating necessary base directories..."
mkdir -p ~/.local ~/.local/share ~/.local/bin ~/.config ~/.config/systemd/user

# Link configurations
echo "Stowing dotfiles..."
for folder in */; do
  folder=${folder%/}

  # Skip specific folders using case
  case "$folder" in
  .git | wallpaper)
    echo "⏭️  Skipping $folder..."
    continue
    ;;
  esac

  echo "🔗 Linking $folder..."
  stow "$folder"
done

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

# Enable Services
echo "Enabling Services... 🔌"
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth

echo "Done! All configurations are linked and setup is complete. 🎉"
