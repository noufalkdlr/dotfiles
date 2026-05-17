#!/bin/bash

echo "🧹 Unstowing dotfiles..."
for folder in */; do
  folder=${folder%/}

  # Skip specific folders using case
  case "$folder" in
  .git | wallpaper)
    echo "⏭️  Skipping $folder..."
    continue
    ;;
  esac

  echo "🗑️ Removing links for $folder..."
  stow -D "$folder"
done

echo "✅ All dotfiles unstowed successfully!"
