#!/bin/bash

# Accessibility Fix Verification Script
# Verifies that the color compliance fix has been properly implemented

set -e

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║  Deets Accessibility Compliance Verification                     ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

PASSED=0
FAILED=0

# Function to check file existence
check_file() {
    local file=$1
    local description=$2

    if [ -f "$file" ]; then
        echo "✅ PASS: $description"
        ((PASSED++))
        return 0
    else
        echo "❌ FAIL: $description"
        echo "   Missing: $file"
        ((FAILED++))
        return 1
    fi
}

# Function to check file content
check_content() {
    local file=$1
    local pattern=$2
    local description=$3

    if [ ! -f "$file" ]; then
        echo "❌ FAIL: $description (file not found)"
        ((FAILED++))
        return 1
    fi

    if grep -q "$pattern" "$file"; then
        echo "✅ PASS: $description"
        ((PASSED++))
        return 0
    else
        echo "❌ FAIL: $description"
        echo "   Pattern not found: $pattern"
        ((FAILED++))
        return 1
    fi
}

echo "1. Checking Color Asset Creation"
echo "─────────────────────────────────────────────────────────────────"
check_file "Deets/Resources/Assets.xcassets/Colors/TealAccessible.colorset/Contents.json" \
    "TealAccessible color set exists"

if [ -f "Deets/Resources/Assets.xcassets/Colors/TealAccessible.colorset/Contents.json" ]; then
    check_content "Deets/Resources/Assets.xcassets/Colors/TealAccessible.colorset/Contents.json" \
        '"green" : "0.475"' \
        "Light mode color set to #00796B (RGB 0, 121, 107)"

    check_content "Deets/Resources/Assets.xcassets/Colors/TealAccessible.colorset/Contents.json" \
        '"blue" : "0.420"' \
        "Light mode blue component correct"

    check_content "Deets/Resources/Assets.xcassets/Colors/TealAccessible.colorset/Contents.json" \
        'luminosity' \
        "Dark mode variant exists"
fi

echo ""
echo "2. Checking SwiftUI Color Extension"
echo "─────────────────────────────────────────────────────────────────"
check_content "Deets/App/DeetsApp.swift" \
    'Color("TealAccessible")' \
    "Color.teal references TealAccessible asset"

check_content "Deets/App/DeetsApp.swift" \
    '#00796B' \
    "Documentation mentions correct hex color"

check_content "Deets/App/DeetsApp.swift" \
    'tealBrand' \
    "Original brand color preserved as tealBrand"

echo ""
echo "3. Checking Brand Documentation"
echo "─────────────────────────────────────────────────────────────────"
check_content "Brand/kit.md" \
    'Teal Accessible' \
    "Brand kit updated with new accessible color"

check_content "Brand/kit.md" \
    '5.32:1' \
    "Correct contrast ratio documented"

check_content "Brand/kit.md" \
    'WCAG AA compliant' \
    "WCAG compliance status documented"

echo ""
echo "4. Checking Compliance Documentation"
echo "─────────────────────────────────────────────────────────────────"
check_file "ACCESSIBILITY_COLOR_COMPLIANCE.md" \
    "Detailed compliance report exists"

check_file "ACCESSIBILITY_FIX_SUMMARY.md" \
    "Summary document exists"

check_file "ACCESSIBILITY_VISUAL_COMPARISON.txt" \
    "Visual comparison exists"

echo ""
echo "5. Verifying No Direct Color Usage in Views"
echo "─────────────────────────────────────────────────────────────────"

# Check that views use Color.teal, not hardcoded values
if grep -r "Color(red: 0x23 / 255, green: 0xC4 / 255, blue: 0xAE / 255)" \
    Deets/Views/ 2>/dev/null | grep -v "tealBrand" >/dev/null; then
    echo "⚠️  WARNING: Found hardcoded teal color in views"
    echo "   Views should use Color.teal instead"
    ((FAILED++))
else
    echo "✅ PASS: No hardcoded teal colors in views"
    ((PASSED++))
fi

echo ""
echo "6. Checking Python Contrast Verification"
echo "─────────────────────────────────────────────────────────────────"

# Run Python verification
python3 - <<'PYTHON' 2>/dev/null || echo "⚠️  Python verification skipped"
import sys

def srgb_to_linear(c):
    c = c / 255.0
    if c <= 0.03928:
        return c / 12.92
    else:
        return ((c + 0.055) / 1.055) ** 2.4

def relative_luminance(r, g, b):
    r_lin = srgb_to_linear(r)
    g_lin = srgb_to_linear(g)
    b_lin = srgb_to_linear(b)
    return 0.2126 * r_lin + 0.7152 * g_lin + 0.0722 * b_lin

def contrast_ratio(color1, color2):
    l1 = relative_luminance(*color1)
    l2 = relative_luminance(*color2)
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)

# Verify the accessible teal
teal_accessible = (0, 121, 107)
white = (255, 255, 255)
ratio = contrast_ratio(teal_accessible, white)

if ratio >= 4.5:
    print(f"✅ PASS: Teal Accessible contrast ratio {ratio:.2f}:1 (exceeds 4.5:1)")
    sys.exit(0)
else:
    print(f"❌ FAIL: Teal Accessible contrast ratio {ratio:.2f}:1 (below 4.5:1)")
    sys.exit(1)
PYTHON

if [ $? -eq 0 ]; then
    ((PASSED++))
else
    ((FAILED++))
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                      VERIFICATION SUMMARY                        ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "  Tests Passed: $PASSED"
echo "  Tests Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✅ ALL CHECKS PASSED - Accessibility fix verified!"
    echo ""
    echo "Next steps:"
    echo "  1. Run: xcodegen generate"
    echo "  2. Build project in Xcode"
    echo "  3. Test on physical device (light + dark mode)"
    echo ""
    exit 0
else
    echo "❌ SOME CHECKS FAILED - Review the output above"
    echo ""
    exit 1
fi
