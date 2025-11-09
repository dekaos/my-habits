#!/bin/bash

# Script to create Habit Hero app icon matching the splash screen logo
# A checkmark inside a progress circle - representing habit completion
# Install ImageMagick: brew install imagemagick (Mac) or apt-get install imagemagick (Linux)

set -e  # Exit on any error

echo "🎨 Creating Habit Hero App Icon (Checkmark + Progress Circle)..."
echo ""

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick not found!"
    echo ""
    echo "Please install it:"
    echo "  Mac:   brew install imagemagick"
    echo "  Linux: sudo apt-get install imagemagick"
    echo ""
    echo "Or use an online icon generator:"
    echo "  - https://icon.kitchen/"
    echo "  - https://appicon.co/"
    exit 1
fi

# Verify ImageMagick version
echo "📦 ImageMagick version:"
if command -v magick &> /dev/null; then
    magick --version | head -1
else
    convert --version | head -1
fi
echo ""

# Remove old icons if they exist
rm -f app_icon.png app_icon_foreground.png

echo "🖼️  Generating main icon with gradient background..."

# Create main app icon with gradient background, progress circle, and checkmark
if magick -size 1024x1024 \
  gradient:'#6366F1-#EC4899' \
  \( +clone -alpha set -virtual-pixel transparent \
     -channel A -blur 0x20 -level 50%,100% +channel \) \
  -compose Over -composite \
  \( -size 1024x1024 xc:none \
     -stroke white -strokewidth 40 -fill none \
     -draw "translate 512,512 circle 0,0 0,-280" \
     -stroke white -strokewidth 50 -fill none \
     -draw "stroke-linecap round stroke-linejoin round translate 512,512 path 'M -120,0 L -30,100 L 150,-120'" \) \
  -compose Over -composite \
  app_icon.png 2>&1; then
  
  # Verify the file was created
  if [ -f "app_icon.png" ]; then
    SIZE=$(identify -format "%wx%h" app_icon.png 2>/dev/null || echo "unknown")
    echo "✅ Main icon created: app_icon.png ($SIZE)"
  else
    echo "❌ Failed to create app_icon.png"
    exit 1
  fi
else
  echo "❌ ImageMagick convert command failed!"
  exit 1
fi

echo ""
echo "🎭 Generating foreground icon for adaptive icons..."

# Create foreground icon (circle + checkmark on transparent background for adaptive icons)
if magick -size 1024x1024 xc:none \
  -stroke white -strokewidth 40 -fill none \
  -draw "translate 512,512 circle 0,0 0,-280" \
  -stroke white -strokewidth 50 -fill none \
  -draw "stroke-linecap round stroke-linejoin round translate 512,512 path 'M -120,0 L -30,100 L 150,-120'" \
  app_icon_foreground.png 2>&1; then
  
  # Verify the file was created
  if [ -f "app_icon_foreground.png" ]; then
    SIZE=$(identify -format "%wx%h" app_icon_foreground.png 2>/dev/null || echo "unknown")
    echo "✅ Foreground icon created: app_icon_foreground.png ($SIZE)"
  else
    echo "❌ Failed to create app_icon_foreground.png"
    exit 1
  fi
else
  echo "❌ ImageMagick convert command failed!"
  exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Success! Icons created successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📱 Icon design:"
echo "   • Progress circle (habit tracker)"
echo "   • Checkmark (completion/achievement)"
echo "   • Gradient background (indigo to pink)"
echo ""
echo "📂 Files created:"
ls -lh app_icon*.png 2>/dev/null || echo "   No files found"
echo ""
echo "🔍 Preview icon (macOS):"
echo "   open app_icon.png"
echo ""
echo "🚀 Next steps:"
echo "   1. cd ../.."
echo "   2. flutter pub run flutter_launcher_icons"
echo "   3. flutter clean"
echo "   4. flutter run --release"
echo ""

