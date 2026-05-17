#!/bin/bash

echo "Starting System Backup... 📂"

# Update Package List
echo "📝 Exporting package list..."
pacman -Qnqe >pkglist.txt

# Update yay Package List
echo " Exporting yay package list..."
pacman -Qmqe >aur-pkglist.txt

# Update GNOME Settings
echo "⚙️ Exporting GNOME settings..."
dconf dump / >gnome-settings.ini

# Push to GitHub
echo "☁️ Pushing to GitHub..."
git add .
# Commit with current timestamp
git commit -m "Auto-backup: $(date '+%Y-%m-%d %H:%M:%S')"
git push

echo "All done! Backup secured in GitHub. ✅"
