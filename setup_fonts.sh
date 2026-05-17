#!/bin/bash

set -e

FONT_DIR="$HOME/.local/share"
ZIP_PATH="/tmp/fonts.zip"
URL="https://github.com/noufalkdlr/dotfiles/releases/download/v1.0/fonts.zip"

echo "----------------------------------------"
echo " 📁 Installing Fonts for Hyprland Setup... "
echo "----------------------------------------"

mkdir -p "$FONT_DIR"

echo "📥 Downloading fonts from GitHub Releases..."
curl -L "$URL" -o "$ZIP_PATH"

echo "📦 Extracting fonts to $FONT_DIR/fonts..."
unzip -o "$ZIP_PATH" -d "$FONT_DIR/"

rm -f "$ZIP_PATH"

echo "🔄 Updating font cache..."
fc-cache -fv

echo "-------------------------------------"
echo " 🎉 Fonts installed successfully! 🚀"
echo "-------------------------------------"
