#!/bin/bash

# Simple script to create app icons using ImageMagick
# Install ImageMagick: brew install imagemagick (Mac) or apt-get install imagemagick (Linux)

echo "🎨 Creating Habit Hero App Icon..."

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick not found!"
    echo "Please install it:"
    echo "  Mac: brew install imagemagick"
    echo "  Linux: sudo apt-get install imagemagick"
    echo ""
    echo "Or use an online icon generator:"
    echo "  - https://icon.kitchen/"
    echo "  - https://appicon.co/"
    exit 1
fi

# Create main app icon with gradient and star (with proper padding)
convert -size 1024x1024 \
  gradient:'#6366F1-#EC4899' \
  \( +clone -alpha set -virtual-pixel transparent \
     -channel A -blur 0x20 -level 50%,100% +channel \) \
  -compose Over -composite \
  \( -size 1024x1024 xc:none -fill white \
     -draw "translate 512,512 path 'M 0,-200 L 60,-60 L 210,-60 L 90,40 L 140,180 L 0,80 L -140,180 L -90,40 L -210,-60 L -60,-60 Z'" \) \
  -compose Over -composite \
  app_icon.png

echo "✅ Main icon created: assets/icon/app_icon.png"

# Create foreground icon (just the star on transparent background with padding)
convert -size 1024x1024 xc:none \
  -fill white \
  -draw "translate 512,512 path 'M 0,-200 L 60,-60 L 210,-60 L 90,40 L 140,180 L 0,80 L -140,180 L -90,40 L -210,-60 L -60,-60 Z'" \
  app_icon_foreground.png

echo "✅ Foreground icon created: assets/icon/app_icon_foreground.png"

echo ""
echo "🚀 Now run: flutter pub run flutter_launcher_icons"

