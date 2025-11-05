# Deets - App Store Screenshot Plan

**Version**: 1.0.0
**Last Updated**: November 5, 2025
**Owner**: LUMEN (Brand & App Store Assets Lead)

---

## Screenshot Strategy

### Objectives

1. **Show Core Value**: Privacy-first business card scanning in 5 screens
2. **Visual Hierarchy**: Hero shot first, features second, privacy third
3. **Clear Messaging**: Each screenshot has ONE clear message
4. **Device Coverage**: iPhone and iPad optimized layouts
5. **Accessibility**: High contrast, readable text, clear actions

### Key Messaging Priorities

1. Fast, easy scanning
2. Smart contact parsing
3. Privacy on-device processing
4. Export flexibility
5. Simple contact management

---

## Required Screenshot Sizes

### iPhone

| Device | Size (px) | Aspect Ratio | Priority |
|--------|-----------|--------------|----------|
| iPhone 15 Pro Max | 1290 × 2796 | 9:19.5 | Required ⭐ |
| iPhone 11 Pro Max | 1242 × 2688 | 9:19.5 | Required ⭐ |
| iPhone 8 Plus | 1242 × 2208 | 9:16 | Required ⭐ |

### iPad

| Device | Size (px) | Aspect Ratio | Priority |
|--------|-----------|--------------|----------|
| iPad Pro 12.9" (6th Gen) | 2048 × 2732 | 3:4 | Required ⭐ |
| iPad Pro 12.9" (2nd Gen) | 2048 × 2732 | 3:4 | Optional |

**Note**: Create master screenshots at highest resolution, then downscale for other sizes.

---

## Screenshot Sequence (5 Screens)

### Screenshot 1: Hero - Scan Screen

**Message**: "Scan business cards instantly"

**Visual Content**:
- Camera viewfinder with business card in frame
- Live text recognition overlay (highlighted text boxes)
- Floating "Scan" button at bottom
- Natural lighting, real business card

**Text Overlay** (if using):
- Top: "Point and Scan"
- Bottom: "Automatic text recognition"

**Design Notes**:
- Use actual camera UI (VisionKit interface)
- Show business card at slight angle (dynamic)
- Text recognition boxes should be teal (#23C4AE)
- Keep UI clean, not cluttered

**Annotations**:
```
┌─────────────────────────────┐
│    [Status Bar]             │
│                             │
│  ┌───────────────────────┐  │
│  │                       │  │
│  │   [Business Card]     │  │
│  │   ┌────────┐          │  │
│  │   │ Name   │ [Box]    │  │
│  │   │ Email  │ [Box]    │  │
│  │   │ Phone  │ [Box]    │  │
│  │   └────────┘          │  │
│  │                       │  │
│  └───────────────────────┘  │
│                             │
│     [Scan Button]           │
└─────────────────────────────┘
```

**Alt Text** (Accessibility):
"Camera viewfinder showing a business card with automatic text detection highlighting name, email, and phone number fields."

---

### Screenshot 2: Contact Preview - Parsed Data

**Message**: "Smart parsing extracts all contact info"

**Visual Content**:
- Contact preview screen with parsed fields
- Profile picture placeholder (optional)
- Form fields: Name, Title, Company, Email, Phone, Website
- "Save" button (teal) at bottom
- "Edit" option visible

**Text Overlay** (if using):
- Top: "Review and Edit"
- Bottom: "All fields auto-filled"

**Design Notes**:
- Use realistic sample data (e.g., "Sarah Chen", "Product Manager")
- Show confidence badges (green check for high confidence)
- Mist background (#F7F9FA)
- White card with shadow for form

**Sample Data**:
```
Name: Sarah Chen
Title: Product Manager
Company: Acme Design Co.
Email: sarah.chen@acme.com
Phone: +1 (555) 123-4567
Website: acme.com
```

**Annotations**:
```
┌─────────────────────────────┐
│  ← Contact Preview          │
│                             │
│  ┌───────────────────────┐  │
│  │  [Photo Placeholder]   │  │
│  ├───────────────────────┤  │
│  │ Name: Sarah Chen ✓    │  │
│  │ Title: Product Mgr ✓  │  │
│  │ Company: Acme Design  │  │
│  │ Email: sarah@... ✓    │  │
│  │ Phone: +1555... ✓     │  │
│  │ Website: acme.com ✓   │  │
│  └───────────────────────┘  │
│                             │
│     [Save Button]           │
└─────────────────────────────┘
```

**Alt Text**:
"Contact preview screen showing auto-filled fields including name, title, company, email, phone, and website with confidence checkmarks."

---

### Screenshot 3: Contact List - Saved Cards

**Message**: "Organize and find contacts easily"

**Visual Content**:
- List of 5-7 saved contacts
- Search bar at top
- Each row: Name, Company, favorite star
- Subtle card separation
- Mix of favorited and non-favorited contacts

**Text Overlay** (if using):
- Top: "All Your Connections"
- Bottom: "Search, filter, and favorite"

**Design Notes**:
- Show diverse names and companies
- Use real-looking data (not Lorem Ipsum)
- At least 1-2 favorite stars (coral #FF766A)
- Search bar with icon (magnifying glass)

**Sample Contacts**:
```
⭐ Sarah Chen | Acme Design Co.
   Marcus Johnson | TechStart Inc.
   Elena Rodriguez | Global Solutions
⭐ David Kim | Creative Agency
   Rachel Adams | Innovate Labs
   James Wilson | Future Corp
```

**Annotations**:
```
┌─────────────────────────────┐
│  Contacts          [+ Add]   │
│  [🔍 Search contacts...]     │
│                             │
│  ⭐ Sarah Chen              │
│     Acme Design Co.          │
│  ─────────────────────────  │
│     Marcus Johnson          │
│     TechStart Inc.          │
│  ─────────────────────────  │
│     Elena Rodriguez         │
│     Global Solutions        │
│  ─────────────────────────  │
│  ⭐ David Kim               │
│     Creative Agency         │
└─────────────────────────────┘
```

**Alt Text**:
"List of saved business contacts with names, companies, and favorite stars. Search bar at top for quick filtering."

---

### Screenshot 4: Privacy Message - On-Device Processing

**Message**: "Everything stays on your device"

**Visual Content**:
- Centered privacy illustration
  - iPhone icon with shield/lock
  - Crossed-out cloud icon
- Large headline: "Your Privacy Matters"
- Subtext: "All processing happens on your device. No cloud. No tracking. No accounts."
- Minimal UI, focus on message

**Text Overlay** (if using):
- Top: "Privacy First"
- Bottom: "No cloud. No tracking. No BS."

**Design Notes**:
- Use teal accent color for shield icon
- Mist background for calm, trustworthy feel
- Keep text large and readable
- No form fields, just messaging

**Visual Hierarchy**:
```
┌─────────────────────────────┐
│                             │
│          🛡️                  │
│       [iPhone]              │
│                             │
│    Everything Stays         │
│    On Your Device           │
│                             │
│  ☁️ ❌                       │
│                             │
│  No cloud processing        │
│  No data tracking           │
│  No account required        │
│                             │
└─────────────────────────────┘
```

**Alt Text**:
"Privacy illustration showing a phone with shield icon and crossed-out cloud, emphasizing on-device processing without cloud storage."

---

### Screenshot 5: Export Options - Share & Export

**Message**: "Export anywhere, anytime"

**Visual Content**:
- Contact detail screen with export options
- iOS Share Sheet visible
- Options: Export to Contacts, VCF, CSV
- Highlighted "Export to Contacts" button
- Optional: AirDrop, Messages, Mail icons

**Text Overlay** (if using):
- Top: "Export Your Way"
- Bottom: "Contacts, VCF, or CSV"

**Design Notes**:
- Show real iOS Share Sheet (native feel)
- Teal highlight on primary action
- Contact card visible behind sheet
- Keep share options realistic (no random apps)

**Annotations**:
```
┌─────────────────────────────┐
│  Contact Detail      [...]   │
│                             │
│  Sarah Chen                 │
│  Product Manager            │
│  Acme Design Co.            │
│                             │
│  ┌───────────────────────┐  │
│  │  Export to Contacts   │  │← Teal
│  │  Export as VCF        │  │
│  │  Export as CSV        │  │
│  │  ─────────────────    │  │
│  │  AirDrop              │  │
│  │  Messages             │  │
│  │  Mail                 │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

**Alt Text**:
"Export options screen showing iOS Share Sheet with choices to export to Contacts, VCF, or CSV, plus sharing via AirDrop, Messages, and Mail."

---

## Screenshot Design Specifications

### Typography

**Headlines** (if using text overlays):
- Font: SF Pro Display Bold
- Size: 48-64pt (iPhone), 72-96pt (iPad)
- Color: Graphite (#2B2E3A) or White (on dark)
- Alignment: Center or Left (depending on design)

**Subtext**:
- Font: SF Pro Text Regular
- Size: 24-32pt (iPhone), 36-48pt (iPad)
- Color: Slate (#6B7280)
- Alignment: Center or Left

**UI Text** (app interface):
- Font: SF Pro (system default)
- Size: Follow iOS HIG (17pt body, 22pt title2, etc.)
- Color: Graphite (#2B2E3A) or White

### Color Scheme

**Backgrounds**:
- Primary: Mist (#F7F9FA)
- Cards: White (#FFFFFF) with subtle shadow
- Dark elements: Graphite (#2B2E3A)

**Accents**:
- Primary CTA: Teal (#23C4AE)
- Favorites: Coral (#FF766A)
- Success indicators: Green (#10B981)

**Text**:
- Primary: Graphite (#2B2E3A)
- Secondary: Slate (#6B7280)
- On dark: White (#FFFFFF)

### Layout Guidelines

**Safe Areas**:
- Top margin: 64px (status bar + nav bar)
- Bottom margin: 34px (home indicator)
- Side margins: 20px (iPhone), 40px (iPad)

**Card Shadows**:
- Offset: 0, 4px
- Blur: 12px
- Color: rgba(0, 0, 0, 0.08)

**Corner Radius**:
- Cards: 12px
- Buttons: 8px
- Input fields: 8px

---

## Dark Mode Variants

### Strategy

**Option A**: Light mode only (recommended for App Store)
- Reason: Most users view App Store in light mode
- Simpler to produce (5 screenshots vs 10)
- Easier to maintain consistency

**Option B**: Light + Dark mode (10 total screenshots)
- Reason: Shows dark mode support
- Appeals to dark mode users
- More work to produce and maintain

**Recommendation**: Start with light mode only. Add dark variants if user feedback requests it.

---

## Device-Specific Adjustments

### iPhone (6.7", 6.5", 5.5")

**Differences**:
- Portrait orientation only
- Taller aspect ratio (more vertical space)
- Navigation at top, actions at bottom
- Single column layout

**Optimization**:
- Use full height for hero images
- Place text overlays in safe areas
- Ensure buttons are thumb-reachable (bottom third)

### iPad (12.9")

**Differences**:
- Landscape or portrait (choose portrait for consistency)
- More horizontal space
- Larger text and UI elements
- Potential for multi-column layouts

**Optimization**:
- Increase font sizes (1.5× iPhone sizes)
- Use two-column layouts where appropriate
- Larger tap targets (follow iPad HIG)
- More breathing room (whitespace)

---

## Text Overlay Strategy

### Option A: No Text Overlays (Recommended)

**Pros**:
- Shows actual app UI (authentic)
- No localization needed
- Cleaner, more professional
- Users see real screenshots

**Cons**:
- Less marketing-friendly
- Requires UI to be self-explanatory

### Option B: Minimal Text Overlays

**Pros**:
- Highlights key features
- Guides user attention
- Marketing-friendly

**Cons**:
- Requires localization for each language
- Can look dated quickly
- Overlays may obscure UI

**Recommendation**: Use NO text overlays. Let the UI and natural content speak for itself. Add text only if A/B testing shows it improves conversion.

---

## Production Workflow

### Step 1: Design in Figma/Sketch

1. Create artboards for each device size
2. Design all 5 screenshots at highest resolution
3. Use iOS UI kit for authenticity
4. Export at 1× (actual pixel size)

### Step 2: Capture Real Screenshots

1. Build app in Xcode
2. Run on Simulator (iPhone 15 Pro Max)
3. Use demo data (see sample data below)
4. Capture screenshots: Cmd+S (Simulator)
5. Save to Desktop

### Step 3: Enhance in Design Tool (Optional)

1. Import screenshots into Figma/Photoshop
2. Add subtle enhancements (brightness, contrast)
3. DO NOT alter UI elements
4. Export at original resolution

### Step 4: Generate Additional Sizes

1. Use Xcode's Screenshot tool OR
2. Run app on each Simulator size
3. Capture same screens for each device
4. OR use Figma's resize frames (faster but less accurate)

### Step 5: Review & Validate

1. Check all sizes are correct dimensions
2. Verify text is readable at thumbnail size
3. Test in App Store Connect preview
4. Get approval from brand lead (LUMEN)

---

## Sample Data for Screenshots

### Contact 1 (Featured)
```
Name: Sarah Chen
Title: Product Manager
Company: Acme Design Co.
Email: sarah.chen@acme.com
Phone: +1 (555) 123-4567
Website: acme.com
```

### Contact 2
```
Name: Marcus Johnson
Title: Senior Engineer
Company: TechStart Inc.
Email: m.johnson@techstart.io
Phone: +1 (555) 234-5678
```

### Contact 3
```
Name: Elena Rodriguez
Title: Marketing Director
Company: Global Solutions
Email: elena.r@global.com
Phone: +1 (555) 345-6789
```

### Contact 4
```
Name: David Kim
Title: Creative Director
Company: Creative Agency
Email: david@creativeagency.com
Phone: +1 (555) 456-7890
```

### Contact 5
```
Name: Rachel Adams
Title: VP Operations
Company: Innovate Labs
Email: rachel.adams@innovatelabs.com
Phone: +1 (555) 567-8901
```

**Note**: Use diverse names and realistic companies. Avoid Lorem Ipsum or obviously fake data.

---

## Screenshot File Naming

### Naming Convention
```
Deets_Screenshot_{ScreenNumber}_{DeviceType}.png

Examples:
Deets_Screenshot_1_iPhone67.png
Deets_Screenshot_1_iPhone65.png
Deets_Screenshot_1_iPhone55.png
Deets_Screenshot_1_iPad129.png
```

### Device Codes
- iPhone67: iPhone 6.7" (15 Pro Max, 14 Pro Max)
- iPhone65: iPhone 6.5" (11 Pro Max, XS Max)
- iPhone55: iPhone 5.5" (8 Plus)
- iPad129: iPad Pro 12.9"

---

## App Store Connect Upload Checklist

Before uploading screenshots:

- [ ] All 5 screenshots created for iPhone 6.7"
- [ ] All 5 screenshots created for iPhone 6.5"
- [ ] All 5 screenshots created for iPhone 5.5"
- [ ] All 5 screenshots created for iPad 12.9" (optional)
- [ ] File sizes under 50MB each
- [ ] Correct dimensions verified
- [ ] Screenshots in correct order (1-5)
- [ ] No text overlays that need localization
- [ ] All screenshots show app in best light
- [ ] Privacy messaging is prominent (Screenshot 4)
- [ ] Export functionality is clear (Screenshot 5)

---

## Localization Strategy

### English (Default)
- Use screenshots as designed
- No text overlays needed

### Future Languages
If adding text overlays:
- Spanish, French, German, Japanese, Chinese
- Translate overlay text only (not UI)
- Keep UI screenshots English (or fully localize UI)

**Recommendation**: Avoid text overlays to skip localization entirely.

---

## A/B Testing Plan

### Test 1: Text Overlays vs No Overlays

**Variant A**: No text overlays (clean UI)
**Variant B**: Minimal text overlays (marketing)

Measure: Conversion rate (views → downloads)
Duration: 60 days
Winner: Highest conversion rate

### Test 2: Screenshot Order

**Order A**: Scan → Parse → List → Privacy → Export (current)
**Order B**: Privacy → Scan → Parse → Export → List (privacy-first)

Measure: Time on page, conversion rate
Duration: 60 days

### Test 3: Privacy Screenshot Style

**Style A**: Illustrated (icon-based)
**Style B**: Real UI (settings screen)

Measure: Conversion rate, user feedback
Duration: 30 days

---

## Tools & Resources

### Design Tools
- **Figma**: Collaborative design, iOS UI kits
- **Sketch**: macOS only, iOS templates
- **Adobe XD**: Cross-platform, prototyping

### Screenshot Tools
- **Xcode Simulator**: Free, built-in, accurate
- **Fastlane Screenshots**: Automated screenshot generation
- **Screenshot Creator**: Online tool for quick mocks

### Asset Management
- **App Store Connect**: Official upload portal
- **GitHub**: Version control for design files
- **Dropbox/Drive**: Share with team

---

## Maintenance Schedule

### Update Screenshots When:
- [ ] Major UI redesign (new app version)
- [ ] iOS visual updates (new iOS version released)
- [ ] New key features added
- [ ] Privacy policy changes
- [ ] User feedback suggests confusion

### Review Schedule:
- **Monthly**: Check if screenshots still represent current UI
- **Quarterly**: Review conversion rates, test variations
- **Yearly**: Full redesign to match current iOS aesthetics

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-05 | Initial screenshot plan |

---

## Contact

For screenshot design questions:
**Email**: brand@deets.app
**Owner**: LUMEN (Brand & App Store Assets Lead)

For screenshot generation (Xcode/Simulator):
**Email**: dev@deets.app
**Owner**: Development Team

**Last Updated**: November 5, 2025
**Version**: 1.0.0
