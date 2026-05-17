#!/bin/bash

set -e

echo "Starting System Backup... 📂"

# Update Package List
echo "📝 Exporting package list..."
pacman -Qnqe >pkglist.txt

# Update yay Package List
echo " Exporting yay package list..."
pacman -Qmqe >aur-pkglist.txt

# Push to GitHub
echo "☁️ Pushing to GitHub..."
git add .

if ! git diff-index --quiet HEAD; then
  git commit -m "Auto-backup: $(date '+%Y-%m-%d %H:%M:%S')"
  git push origin main
  echo "All done! Backup secured in GitHub. ✅"
else
  echo "No changes to backup. Everything is up to date! ✨"
fi
