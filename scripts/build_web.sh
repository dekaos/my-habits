#!/bin/bash
# Build script for Habit Hero Landing Page (Flutter Web)

set -e

echo "🚀 Building Habit Hero Landing Page for Web..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo -e "${BLUE}📦 Cleaning previous build...${NC}"
flutter clean

echo -e "${BLUE}📥 Getting dependencies...${NC}"
flutter pub get

echo ""
echo -e "${YELLOW}Choose build mode:${NC}"
echo "1) Development (debug mode)"
echo "2) Production (release mode)"
read -p "Enter choice [1-2]: " choice

case $choice in
    1)
        echo ""
        echo -e "${BLUE}🔨 Building for development...${NC}"
        flutter build web \
            -t lib/main_web.dart \
            --dart-define=ENVIRONMENT=development --wasm
        
        echo ""
        echo -e "${GREEN}✅ Development build complete!${NC}"
        echo -e "${BLUE}📂 Output: build/web/${NC}"
        echo ""
        echo -e "${YELLOW}To serve locally:${NC}"
        echo "  cd build/web && python3 -m http.server 8000"
        echo "  Then open: http://localhost:8000"
        ;;
    2)
        echo ""
        echo -e "${BLUE}🔨 Building for production...${NC}"
        flutter build web \
            -t lib/main_web.dart \
            --release \
            --dart-define=ENVIRONMENT=production --wasm
        
        echo ""
        echo -e "${GREEN}✅ Production build complete!${NC}"
        echo -e "${BLUE}📂 Output: build/web/${NC}"
        echo ""
        echo -e "${YELLOW}Ready to deploy!${NC}"
        echo ""
        echo "Deploy options:"
        echo "  • Firebase: firebase deploy --only hosting"
        echo "  • Netlify: netlify deploy --prod --dir=build/web"
        echo "  • Vercel: cd build/web && vercel --prod"
        ;;
    *)
        echo "❌ Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Done!${NC}"

