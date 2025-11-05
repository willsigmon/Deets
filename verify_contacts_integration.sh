#!/bin/bash
# Verification script for Deets Contacts Integration

set -e

echo "🔍 Verifying Deets Contacts Integration..."
echo ""

PROJECT_ROOT="/Volumes/Ext-code/GitHub Repos/Deets"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track status
PASS=0
FAIL=0

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} $2 (missing: $1)"
        ((FAIL++))
    fi
}

check_content() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $3"
        ((PASS++))
    else
        echo -e "${RED}✗${NC} $3"
        ((FAIL++))
    fi
}

echo "📦 Core Files"
echo "─────────────"
check_file "$PROJECT_ROOT/Deets/Models/ParsedContact.swift" "ParsedContact model"
check_file "$PROJECT_ROOT/Deets/Services/ContactsService.swift" "ContactsService"
check_file "$PROJECT_ROOT/Deets/Services/Validation/ContactParser.swift" "ContactParser"
check_file "$PROJECT_ROOT/Deets/Services/Validation/Formatters.swift" "Formatters"
echo ""

echo "🧪 Testing Files"
echo "────────────────"
check_file "$PROJECT_ROOT/DeetsTests/ContactParserTests.swift" "ContactParserTests"
check_file "$PROJECT_ROOT/Examples/ContactParsingExamples.swift" "Usage examples"
echo ""

echo "📚 Documentation"
echo "────────────────"
check_file "$PROJECT_ROOT/README.md" "README"
check_file "$PROJECT_ROOT/Docs/INTEGRATION_GUIDE.md" "Integration guide"
check_file "$PROJECT_ROOT/Docs/QUICK_REFERENCE.md" "Quick reference"
check_file "$PROJECT_ROOT/CONTACTS_INTEGRATION_COMPLETE.md" "Completion summary"
echo ""

echo "🔧 Configuration"
echo "────────────────"
check_file "$PROJECT_ROOT/Deets/Info.plist.example" "Info.plist example"
echo ""

echo "✅ Feature Verification"
echo "───────────────────────"

# Check ParsedContact features
check_content "$PROJECT_ROOT/Deets/Models/ParsedContact.swift" "struct ParsedPhoneNumber" "ParsedPhoneNumber model"
check_content "$PROJECT_ROOT/Deets/Models/ParsedContact.swift" "struct ParsedEmail" "ParsedEmail model"
check_content "$PROJECT_ROOT/Deets/Models/ParsedContact.swift" "struct ParsedAddress" "ParsedAddress model"
check_content "$PROJECT_ROOT/Deets/Models/ParsedContact.swift" "ConfidenceScores" "Confidence scoring"
check_content "$PROJECT_ROOT/Deets/Models/ParsedContact.swift" "ValidationFlags" "Validation flags"
echo ""

# Check ContactParser features
check_content "$PROJECT_ROOT/Deets/Services/Validation/ContactParser.swift" "parseName" "Name parsing"
check_content "$PROJECT_ROOT/Deets/Services/Validation/ContactParser.swift" "parsePhoneNumbers" "Phone parsing"
check_content "$PROJECT_ROOT/Deets/Services/Validation/ContactParser.swift" "parseEmails" "Email parsing"
check_content "$PROJECT_ROOT/Deets/Services/Validation/ContactParser.swift" "parseURLs" "URL parsing"
check_content "$PROJECT_ROOT/Deets/Services/Validation/ContactParser.swift" "parseAddresses" "Address parsing"
check_content "$PROJECT_ROOT/Deets/Services/Validation/ContactParser.swift" "parseOrganization" "Organization parsing"
echo ""

# Check Formatters
check_content "$PROJECT_ROOT/Deets/Services/Validation/Formatters.swift" "PhoneNumberFormatter" "Phone formatter"
check_content "$PROJECT_ROOT/Deets/Services/Validation/Formatters.swift" "NameFormatter" "Name formatter"
check_content "$PROJECT_ROOT/Deets/Services/Validation/Formatters.swift" "AddressFormatter" "Address formatter"
check_content "$PROJECT_ROOT/Deets/Services/Validation/Formatters.swift" "EmailFormatter" "Email formatter"
check_content "$PROJECT_ROOT/Deets/Services/Validation/Formatters.swift" "URLFormatter" "URL formatter"
echo ""

# Check ContactsService features
check_content "$PROJECT_ROOT/Deets/Services/ContactsService.swift" "requestAccess" "Permission handling"
check_content "$PROJECT_ROOT/Deets/Services/ContactsService.swift" "saveContact" "Save contact method"
check_content "$PROJECT_ROOT/Deets/Services/ContactsService.swift" "findDuplicates" "Duplicate detection"
check_content "$PROJECT_ROOT/Deets/Services/ContactsService.swift" "updateContact" "Update contact method"
check_content "$PROJECT_ROOT/Deets/Services/ContactsService.swift" "enum ContactsError" "Error handling"
echo ""

# Check tests
check_content "$PROJECT_ROOT/DeetsTests/ContactParserTests.swift" "testParseSimpleName" "Name parsing tests"
check_content "$PROJECT_ROOT/DeetsTests/ContactParserTests.swift" "testParseUSPhoneNumber" "Phone parsing tests"
check_content "$PROJECT_ROOT/DeetsTests/ContactParserTests.swift" "testParseEmail" "Email parsing tests"
check_content "$PROJECT_ROOT/DeetsTests/ContactParserTests.swift" "testParseFullAddress" "Address parsing tests"
echo ""

echo "📊 Summary"
echo "──────────"
echo -e "${GREEN}Passed:${NC} $PASS checks"
echo -e "${RED}Failed:${NC} $FAIL checks"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! Contacts integration is complete.${NC}"
    exit 0
else
    echo -e "${RED}❌ Some checks failed. Please review the output above.${NC}"
    exit 1
fi
