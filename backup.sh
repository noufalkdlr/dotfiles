#!/bin/bash
set -e

echo "Starting System Backup... 📂"

# Update Package List (excluding hardware-specific packages)
echo "📝 Exporting package list..."
pacman -Qnqe | grep -vE '^(nvidia-open-dkms|libva-nvidia-driver|intel-ucode|amd-ucode|xf86-video-amdgpu|xf86-video-intel|vulkan-radeon|lib32-vulkan-radeon|vulkan-intel|lib32-vulkan-intel|linux|linux-firmware|linux-headers|linux-zen|linux-zen-headers|sof-firmware)$' >pkglist.txt

# Update yay Package List
echo " Exporting yay package list..."
pacman -Qmqe >aur-pkglist.txt

# Push to GitHub
echo "☁️ Pushing to GitHub..."
git add .

if ! git diff-index --quiet HEAD; then
  git commit -m "Auto-backup: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "✅ Changes committed."
else
  echo "✨ No new changes to commit."
fi

git push origin main

echo "🎉 All done! Backup secured in GitHub."
