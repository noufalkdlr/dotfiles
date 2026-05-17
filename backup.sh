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
  echo "✅ Changes committed."
else
  echo "✨ No new changes to commit."
fi

git push origin main

echo "🎉 All done! Backup secured in GitHub."
