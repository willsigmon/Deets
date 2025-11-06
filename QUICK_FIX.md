# Quick Fix Reference Card

## 🚨 Critical Fix - Do This First!

### Fix Module Name Error

**In Xcode:**
1. Select project → Select target → Build Settings
2. Search: **"Product Module Name"**
3. Set to: `Deets`
4. Search: **"Product Name"** 
5. Set to: `Deets`
6. Clean Build Folder (⇧⌘K)

**This fixes:**
- ✅ Module name "" is not a valid identifier
- ✅ lstat errors for .swiftmodule, .abi.json, etc.
- ✅ Command CodeSign failed

---

## 📦 Add Required Files

### Copy these files to your Xcode project:

```
✓ Info.plist → Project root
✓ Assets.xcassets/ → Resources folder
  ├── Contents.json
  ├── AppIcon.appiconset/
  │   └── Contents.json
  └── TealAccessible.colorset/
      └── Contents.json
```

**This fixes:**
- ✅ None of the input catalogs contained AppIcon
- ✅ Missing Info.plist errors

---

## 🔄 Check for Duplicates

**In Xcode:**
1. Project → Targets section
2. Delete any duplicate "Deets" targets
3. Select remaining target → Build Phases
4. Expand "Copy Bundle Resources"
5. Remove duplicate file entries

**This fixes:**
- ✅ Multiple commands produce .app
- ✅ Multiple commands produce Info.plist

---

## 🧹 Clean Build

**Always do this after making changes:**

```bash
# Option 1: In Xcode
Product → Clean Build Folder (⇧⌘K)

# Option 2: Terminal
rm -rf ~/Library/Developer/Xcode/DerivedData/Deets-*
```

---

## 🎨 Setup Assets in Xcode

If files don't work, create in Xcode directly:

1. **Asset Catalog:**
   - File → New → Asset Catalog → "Assets"
   
2. **App Icon:**
   - Right-click in Assets.xcassets → New App Icon → "AppIcon"
   
3. **Teal Color:**
   - Right-click → New Color Set → "TealAccessible"
   - Light mode: RGB(0, 121, 107) or #00796B
   - Dark mode: RGB(35, 196, 174) or #23C4AE

---

## ✅ Verify Success

Run this command:
```bash
chmod +x verify-build-setup.sh
./verify-build-setup.sh
```

Or check manually:
- [ ] Product Module Name = "Deets"
- [ ] Info.plist exists in project
- [ ] AppIcon.appiconset in Assets.xcassets
- [ ] TealAccessible.colorset in Assets.xcassets
- [ ] Only ONE Deets target exists
- [ ] Clean build completes without errors

---

## 🆘 Still Having Issues?

1. **Read full guide:** BUILD_FIX_INSTRUCTIONS.md
2. **Check Xcode version:** Requires Xcode 14+ for iOS 16+ features
3. **Verify deployment target:** iOS 16.0 or later
4. **Check file locations:** All paths must match Build Settings

---

## ⚡️ One-Minute Fix

```bash
# 1. Set module name in Xcode Build Settings to "Deets"
# 2. Run this in Terminal:
chmod +x verify-build-setup.sh
./verify-build-setup.sh

# 3. Follow any error messages
# 4. Clean build in Xcode (⇧⌘K)
# 5. Build (⌘B)
```

---

**Remember:** The module name issue is the root cause. Fix that first! 🎯
