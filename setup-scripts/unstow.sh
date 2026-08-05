#!/bin/bash

# Always run from dotfiles root
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

echo "🧹 Unstowing dotfiles..."
for folder in */; do
  folder=${folder%/}

  # Skip specific folders using case
  case "$folder" in
  .git | wallpaper | setup-scripts)
    echo "⏭️  Skipping $folder..."
    continue
    ;;
  esac

  echo "🗑️ Removing links for $folder..."
  stow -D "$folder"
done

echo "✅ All dotfiles unstowed successfully!"
