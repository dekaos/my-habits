#!/bin/bash
# Development server for Habit Hero Landing Page (Flutter Web)

set -e

echo "🌐 Starting Habit Hero Landing Page (Development Mode)..."
echo ""

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo -e "${BLUE}📦 Getting dependencies...${NC}"
flutter pub get

echo ""
echo -e "${GREEN}🚀 Launching web server...${NC}"
echo -e "${BLUE}Opening in Chrome...${NC}"
echo ""

# Run Flutter web in development mode
flutter run \
    -d chrome \
    -t lib/main_web.dart \
    --web-port=8080

echo ""
echo -e "${GREEN}✅ Server stopped${NC}"

