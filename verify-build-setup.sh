#!/bin/bash

# Deets Build Environment Verification Script
# Run this script to verify your Xcode project configuration

set -e

echo "🔍 Deets Build Configuration Verification"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall status
ISSUES_FOUND=0

# Check if we're in the right directory
if [ ! -f "DeetsApp.swift" ]; then
    echo -e "${RED}❌ Error: This script must be run from the Deets project directory${NC}"
    exit 1
fi

echo "📁 Checking Project Structure..."
echo ""

# Check for Info.plist
if [ -f "Info.plist" ]; then
    echo -e "${GREEN}✓${NC} Info.plist exists"
else
    echo -e "${RED}✗${NC} Info.plist is missing"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check for Assets.xcassets
if [ -d "Resources/Assets.xcassets" ] || [ -d "Assets.xcassets" ]; then
    echo -e "${GREEN}✓${NC} Assets.xcassets exists"
    
    # Check for AppIcon
    if [ -d "Resources/Assets.xcassets/AppIcon.appiconset" ] || [ -d "Assets.xcassets/AppIcon.appiconset" ]; then
        echo -e "${GREEN}✓${NC} AppIcon.appiconset exists"
    else
        echo -e "${RED}✗${NC} AppIcon.appiconset is missing"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
    
    # Check for TealAccessible color
    if [ -d "Resources/Assets.xcassets/TealAccessible.colorset" ] || [ -d "Assets.xcassets/TealAccessible.colorset" ]; then
        echo -e "${GREEN}✓${NC} TealAccessible.colorset exists"
    else
        echo -e "${YELLOW}⚠${NC} TealAccessible.colorset is missing (app will fail to launch)"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    echo -e "${RED}✗${NC} Assets.xcassets directory is missing"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

echo ""
echo "📝 Checking File Contents..."
echo ""

# Check Info.plist for required keys
if [ -f "Info.plist" ]; then
    # Check for camera permission
    if grep -q "NSCameraUsageDescription" Info.plist; then
        echo -e "${GREEN}✓${NC} Camera permission description found"
    else
        echo -e "${RED}✗${NC} Camera permission description missing"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
    
    # Check for contacts permission
    if grep -q "NSContactsUsageDescription" Info.plist; then
        echo -e "${GREEN}✓${NC} Contacts permission description found"
    else
        echo -e "${RED}✗${NC} Contacts permission description missing"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
    
    # Check for bundle name
    if grep -q "CFBundleName" Info.plist; then
        echo -e "${GREEN}✓${NC} Bundle name configured"
    else
        echo -e "${RED}✗${NC} Bundle name missing"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
fi

echo ""
echo "🔨 Checking Build Environment..."
echo ""

# Check if DerivedData exists (indicates previous build attempts)
if [ -d "$HOME/Library/Developer/Xcode/DerivedData" ]; then
    DEETS_DERIVED=$(find "$HOME/Library/Developer/Xcode/DerivedData" -name "Deets-*" -type d 2>/dev/null | head -n 1)
    if [ -n "$DEETS_DERIVED" ]; then
        echo -e "${YELLOW}⚠${NC} DerivedData exists for Deets"
        echo "   Location: $DEETS_DERIVED"
        echo "   Recommendation: Clean build folder in Xcode (⇧⌘K)"
    else
        echo -e "${GREEN}✓${NC} No stale DerivedData found"
    fi
else
    echo -e "${GREEN}✓${NC} DerivedData directory clean"
fi

echo ""
echo "=========================================="
echo ""

# Summary
if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Open the project in Xcode"
    echo "2. Verify Build Settings (see BUILD_FIX_INSTRUCTIONS.md)"
    echo "3. Clean Build Folder (⇧⌘K)"
    echo "4. Build the project (⌘B)"
else
    echo -e "${RED}⚠️  Found $ISSUES_FOUND issue(s)${NC}"
    echo ""
    echo "Please review BUILD_FIX_INSTRUCTIONS.md for detailed fix steps"
    echo ""
    echo "Quick fixes:"
    
    if [ ! -f "Info.plist" ]; then
        echo "• Copy Info.plist to your project directory"
    fi
    
    if [ ! -d "Resources/Assets.xcassets" ] && [ ! -d "Assets.xcassets" ]; then
        echo "• Create Assets.xcassets in Xcode (File → New → Asset Catalog)"
    fi
    
    if [ ! -d "Resources/Assets.xcassets/AppIcon.appiconset" ] && [ ! -d "Assets.xcassets/AppIcon.appiconset" ]; then
        echo "• Add AppIcon to Assets.xcassets (Right-click → New App Icon)"
    fi
    
    if [ ! -d "Resources/Assets.xcassets/TealAccessible.colorset" ] && [ ! -d "Assets.xcassets/TealAccessible.colorset" ]; then
        echo "• Add TealAccessible color set to Assets.xcassets"
    fi
fi

echo ""
echo "📖 For complete instructions, see: BUILD_FIX_INSTRUCTIONS.md"
echo ""

exit $ISSUES_FOUND
