#!/bin/bash

echo "Setting up dotfiles..."

# Link configurations
echo "Stowing dotfiles..."
for folder in */; do
  folder=${folder%/}

  if [ "$folder" == ".git" ]; then
    continue
  fi

  echo "🔗 Linking $folder..."
  stow "$folder"
done

# Install packages
if [ -f "pkglist.txt" ]; then
  echo "Installing packages from list... 📦"
  sudo pacman -S --needed - <"pkglist.txt"
else
  echo "Error: pkglist.txt not found! ❌"
fi

# Restore GNOME settings
if [ -f "gnome-settings.ini" ]; then
  echo "Loading GNOME settings..."
  dconf load / <gnome-settings.ini
else
  echo "Warning: gnome-settings.ini not found, skipping..."
fi

# Refresh Font Cache (Added for Malayalam fonts fix)
echo "Updating font cache..."
fc-cache -fv

echo "Done! All configurations are linked and setup is complete. 🎉"
