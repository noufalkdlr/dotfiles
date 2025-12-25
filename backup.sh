#!/bin/bash

echo "Starting System Backup... 📂"

# 1. Update Package List
echo "📝 Exporting package list..."
pacman -Qnqe >pkglist.txt

# 2. Update GNOME Settings
echo "⚙️ Exporting GNOME settings..."
dconf dump / >gnome-settings.ini

# 3. Push to GitHub
echo "☁️ Pushing to GitHub..."
git add .
# Commit with current timestamp
git commit -m "Auto-backup: $(date '+%Y-%m-%d %H:%M:%S')"
git push

echo "All done! Backup secured in GitHub. ✅"
