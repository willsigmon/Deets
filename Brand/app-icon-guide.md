# Deets App Icon Guide

**Version**: 1.0.0
**Last Updated**: November 5, 2025
**Owner**: LUMEN (Brand & App Store Assets Lead)

---

## Icon Concept

The Deets app icon features two interlocking circular dots forming an abstract "D" on a gradient teal background. This design embodies:

- **Connection**: Two people meeting and exchanging information
- **Privacy**: Separate, distinct entities maintaining boundaries
- **Simplicity**: Clean, modern, instantly recognizable

---

## Master Icon Specifications

### Dimensions

**Primary Size**: 1024 × 1024 pixels
**Format**: PNG (24-bit with alpha)
**Color Space**: sRGB (IEC61966-2.1)
**DPI**: 72 (standard for App Store)

### Background

**Type**: Linear gradient
**Start Color**: Teal `#23C4AE` (top)
**End Color**: Darker Teal `#1FA896` (bottom)
**Gradient Angle**: 180° (top to bottom)
**Alternative**: Radial gradient from center (lighter) to edges (darker)

### Icon Elements

**Element**: Two overlapping circles (dots)
**Circle Color**: Pure White `#FFFFFF`
**Opacity**: 90% (allows gradient to show through subtly)
**Size**: Each circle is 40% of canvas width
**Positioning**: See detailed layout below

---

## Detailed Layout (1024×1024px)

### Grid System

```
Canvas: 1024 × 1024px
Safe Area (inner): 896 × 896px (64px margin on all sides)
Optical Center: 512, 512 (x, y)
```

### Circle Specifications

**Left Circle**:
- Diameter: 410px
- Center Point: (390, 512)
- Color: White `#FFFFFF`
- Opacity: 90%

**Right Circle**:
- Diameter: 410px
- Center Point: (634, 512)
- Color: White `#FFFFFF`
- Opacity: 90%

**Overlap**:
- Overlap Width: ~166px (40% of circle diameter)
- Creates distinctive "D" shape
- Overlap area appears slightly darker due to 90% opacity blending

### Geometric Construction

```
┌────────────────────────────────────────┐
│         1024px × 1024px Canvas         │
│                                        │
│   ┌────────────────────────────┐      │
│   │     64px Safe Margin        │      │
│   │                             │      │
│   │      ●●                     │      │
│   │    ●●  ●●                   │      │
│   │   ●●    ●●                  │      │
│   │   ●●    ●●                  │      │
│   │    ●●  ●●                   │      │
│   │      ●●                     │      │
│   │                             │      │
│   │    [Interlocking Dots]      │      │
│   │                             │      │
│   └────────────────────────────┘      │
│                                        │
└────────────────────────────────────────┘

Background: Teal gradient (#23C4AE → #1FA896)
Dots: White at 90% opacity
```

---

## Design Templates

### Sketch Template

**Layer Structure**:
```
Deets-AppIcon-Master
├── Background
│   └── Gradient (Teal #23C4AE → #1FA896)
├── Icon Elements
│   ├── Left Circle (410px, center: 390,512)
│   └── Right Circle (410px, center: 634,512)
└── Safe Area Guide (64px margins, non-printing)
```

### Figma Template

**Layers**:
1. **Frame**: 1024×1024px, named "App Icon"
2. **Background**: Rectangle with linear gradient
   - Color 1: `#23C4AE` at 0%
   - Color 2: `#1FA896` at 100%
3. **Left Dot**: Circle, 410×410px, white, 90% opacity
4. **Right Dot**: Circle, 410×410px, white, 90% opacity
5. **Guides**: Safe area frame (896×896px, centered)

### Adobe Illustrator Template

**Artboard**: 1024×1024px
**Units**: Pixels
**Color Mode**: RGB
**Resolution**: 72 PPI

**Steps**:
1. Create artboard (1024×1024px)
2. Draw rectangle (1024×1024px)
3. Apply gradient: Linear, 180°
   - Stop 1: `#23C4AE` at 0%
   - Stop 2: `#1FA896` at 100%
4. Create circle: 410px diameter at (390, 512)
5. Set fill: White, Opacity 90%
6. Duplicate circle, move to (634, 512)
7. Export as PNG: 1024×1024px, 72 DPI

---

## iOS Icon Sizes

Apple requires multiple icon sizes for different contexts. Generate from the 1024×1024px master.

### Required Sizes (App Store)

| Size (px) | Usage | Scale |
|-----------|-------|-------|
| 1024×1024 | App Store listing | @1x |
| 180×180 | iPhone (3×) | @3x |
| 120×120 | iPhone (2×) | @2x |
| 167×167 | iPad Pro | @2x |
| 152×152 | iPad | @2x |
| 76×76 | iPad | @1x |
| 60×60 | iPhone (base) | @1x |
| 40×40 | Spotlight | @1x |
| 29×29 | Settings | @1x |
| 87×87 | Settings (3×) | @3x |
| 80×80 | Spotlight (2×) | @2x |
| 58×58 | Settings (2×) | @2x |
| 20×20 | Notification | @1x |
| 40×40 | Notification (2×) | @2x |
| 60×60 | Notification (3×) | @3x |

### watchOS Sizes (if applicable)

| Size (px) | Usage |
|-----------|-------|
| 1024×1024 | App Store |
| 172×172 | Watch (44mm/45mm) |
| 196×196 | Watch (49mm) |

### macOS Sizes (if applicable)

| Size (px) | Usage | Scale |
|-----------|-------|-------|
| 1024×1024 | App Store | @1x |
| 512×512 | Mac | @1x |
| 256×256 | Mac | @1x |
| 128×128 | Mac | @1x |
| 64×64 | Mac | @1x |
| 32×32 | Mac | @1x |
| 16×16 | Mac | @1x |

---

## Export Settings

### Primary Export (App Store)

**Format**: PNG
**Size**: 1024×1024px
**Color Space**: sRGB (IEC61966-2.1)
**Bit Depth**: 24-bit (no alpha transparency on background)
**Compression**: None (lossless)
**File Size**: ~50-100KB (typical)

### iOS Asset Catalog Export

**Tool**: Xcode Asset Catalog or Icon Generator
**Format**: PNG for all sizes
**Color Profile**: sRGB
**Naming Convention**: `AppIcon.appiconset/icon_XXXxXXX.png`

**Xcode Asset Catalog Structure**:
```
AppIcon.appiconset/
├── Contents.json
├── icon_1024x1024.png
├── icon_180x180.png
├── icon_167x167.png
├── icon_152x152.png
├── icon_120x120.png
├── icon_87x87.png
├── icon_80x80.png
├── icon_76x76.png
├── icon_60x60.png
├── icon_58x58.png
├── icon_40x40.png
├── icon_29x29.png
└── icon_20x20.png
```

### Batch Export Tools

**Recommended Tools**:
1. **Sketch**: Export multiple sizes via "Export Presets"
2. **Figma**: Use "iOS App Icon" plugin
3. **IconKit (online)**: Upload 1024px master, auto-generates all sizes
4. **AppIconMaker.co**: Free online generator
5. **Xcode Asset Catalog Compiler**: Native Xcode tool

---

## Design Guidelines

### Visual Consistency

**Shape**: Always use perfect circles (no ovals or distortions)
**Alignment**: Circles must be vertically centered
**Overlap**: Maintain 40% overlap ratio across all sizes
**Opacity**: Keep white dots at 90% (allows gradient to show through)

### iOS Human Interface Guidelines Compliance

**No Text**: iOS icons should never contain text (use imagery only)
**No Transparency**: Background must be fully opaque (gradient is opaque)
**No Borders**: Avoid adding frames or borders around icon
**Simplicity**: Icon should be recognizable at small sizes (29×29px)
**Uniqueness**: Icon should be distinctive in App Store search results

### Optical Considerations

**Small Size Legibility**:
- At 29×29px, dots may blend together
- Ensure overlap is still visible
- Test icon at all sizes before finalizing

**Color Adjustments for Small Sizes**:
- For sizes under 60×60px, consider increasing white opacity to 95%
- Ensure gradient contrast is visible at thumbnail size

### Accessibility

**Color Contrast**: Teal gradient provides sufficient contrast with white dots
**Avoid Color-Only Meaning**: Icon shape (overlapping circles) is recognizable without color
**High Contrast Mode**: Icon remains legible in accessibility modes

---

## Variations

### Alternative Gradient Directions

**Radial Gradient (from center)**:
- Inner Color: `#2DD4BD` (lighter teal)
- Outer Color: `#1FA896` (darker teal)
- Creates subtle depth

**Diagonal Gradient (top-left to bottom-right)**:
- Start: `#23C4AE`
- End: `#1FA896`
- Angle: 135°

### Seasonal Variants (Not for App Store)

**Holiday Edition** (internal use only):
- Background: Keep teal gradient
- Dots: Add subtle festive color tint (winter: icy blue, spring: soft green)
- Use only for social media, never submit to App Store

### Dark Mode Consideration

**iOS automatically adapts icon**: No separate dark mode icon needed
**If creating custom dark variant**:
- Background: Darker teal (`#1A9B8A` → `#127A6E`)
- Dots: Keep white at 90%

---

## Quality Checklist

Before exporting, verify:

- [ ] Master icon is 1024×1024px
- [ ] Gradient is smooth (no banding)
- [ ] Circles are perfect (not oval)
- [ ] White dots are 90% opacity
- [ ] Background has no transparency
- [ ] Icon is centered in safe area
- [ ] All exported sizes are sharp (no blurriness)
- [ ] File size is under 1MB per icon
- [ ] Color space is sRGB
- [ ] Icon looks clear at 29×29px

---

## Testing

### Visual Testing

1. **Generate all sizes** using export tool
2. **View in Xcode**: Add to Asset Catalog, preview in different contexts
3. **Test on Device**: Install on physical iPhone, check Home Screen
4. **App Store Preview**: View in App Store Connect (before submitting)

### Contexts to Test

- Home Screen (iOS 17+)
- Spotlight Search
- Settings App
- App Store Search Results
- App Store Product Page
- Notification Banner
- Siri Suggestions

### Testing Tools

- Xcode Simulator (view at different scales)
- Physical devices (iPhone 15 Pro, iPad Pro, etc.)
- App Store Connect preview
- Icon testing apps: Icon Preview, AppIcon.co

---

## Common Mistakes to Avoid

**Don't**:
- ❌ Add text or labels to icon
- ❌ Use transparency on background (must be fully opaque)
- ❌ Create different icons for light/dark mode (iOS handles this)
- ❌ Use gradients on dots (keep solid white)
- ❌ Add drop shadows or glows
- ❌ Use more than 2 colors (background gradient + white dots)
- ❌ Create asymmetric designs
- ❌ Use photos or realistic imagery

**Do**:
- ✅ Use perfect circles (not ovals)
- ✅ Maintain consistent overlap ratio
- ✅ Test at all sizes before finalizing
- ✅ Export from 1024×1024px master
- ✅ Use sRGB color space
- ✅ Keep design simple and recognizable

---

## File Naming Conventions

### Master File
`Deets-AppIcon-Master-1024.png`

### Individual Sizes
```
Deets-AppIcon-1024.png   (App Store)
Deets-AppIcon-180.png    (iPhone @3x)
Deets-AppIcon-120.png    (iPhone @2x)
Deets-AppIcon-167.png    (iPad Pro)
Deets-AppIcon-152.png    (iPad @2x)
Deets-AppIcon-76.png     (iPad @1x)
...
```

### Source Files
```
Deets-AppIcon-Master.sketch
Deets-AppIcon-Master.fig
Deets-AppIcon-Master.ai
```

---

## Design Approval Process

### Steps

1. **Designer Creates Master** (1024×1024px in Sketch/Figma)
2. **Export All Sizes** (use batch export tool)
3. **Internal Review** (brand lead approval)
4. **Test on Devices** (iOS team installs on test devices)
5. **App Store Connect Upload** (for TestFlight/beta testing)
6. **Final Approval** (before production release)

### Approval Checklist

- [ ] Brand lead (LUMEN) approves design
- [ ] Design follows brand guidelines
- [ ] All sizes exported correctly
- [ ] Icon tested on physical devices
- [ ] Icon appears correctly in Xcode
- [ ] File sizes are optimized
- [ ] Ready for App Store submission

---

## Resources

### Design Tools

**Icon Generators**:
- [AppIcon.co](https://appicon.co/) - Free online generator
- [MakeAppIcon](https://makeappicon.com/) - Batch export
- [IconKit](https://iconkit.ai/) - AI-powered optimization

**Testing Tools**:
- Xcode Simulator
- [Icon Preview](https://apps.apple.com/us/app/icon-preview/id1533767938) (Mac app)
- Physical devices

### Apple Documentation

- [Human Interface Guidelines - App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Xcode Asset Catalog Format Reference](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/)
- [App Store Connect - Icon Requirements](https://developer.apple.com/app-store/product-page/)

### Design Templates

**Download Templates**:
- Sketch: `Brand/Templates/Deets-AppIcon-Template.sketch`
- Figma: [Link to Figma template]
- Illustrator: `Brand/Templates/Deets-AppIcon-Template.ai`

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-11-05 | Initial app icon guide |

---

## Contact

For questions about app icon design:
**Email**: brand@deets.app
**Owner**: LUMEN (Brand & App Store Assets Lead)

**Last Updated**: November 5, 2025
**Version**: 1.0.0
