#!/bin/bash

# Always run from dotfiles root
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1

echo "🔗 Stowing dotfiles..."
for folder in */; do
  folder=${folder%/}

  case "$folder" in
  .git | wallpaper | setup-scripts)
    echo "⏭️  Skipping $folder..."
    continue
    ;;
  esac

  echo "🔗 Linking $folder..."
  stow "$folder"
done

echo "✅ All dotfiles stowed successfully!"
