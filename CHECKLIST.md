# ✅ Build Fix Checklist

Use this checklist to track your progress fixing the build errors.

## 🚀 Getting Started

- [ ] I have read `QUICK_FIX.md` for overview
- [ ] I have Xcode installed (version 14 or later)
- [ ] I have closed and reopened Xcode
- [ ] I understand the module name is the root cause

---

## 1️⃣ Critical Fix - Module Name (Do This First!)

**Estimated time: 2 minutes**

- [ ] Opened Deets project in Xcode
- [ ] Selected Deets project in navigator (top level)
- [ ] Selected Deets target in main panel
- [ ] Clicked "Build Settings" tab
- [ ] Set filter to "All" and "Combined"
- [ ] Searched for "Product Module Name"
- [ ] Set value to: `Deets`
- [ ] Searched for "Product Name"
- [ ] Set value to: `Deets`
- [ ] Searched for "Product Bundle Identifier"
- [ ] Set value to: `com.[your-team].Deets` (replace [your-team])
- [ ] Pressed ⌘S to save

**Verification:**
- [ ] Product Module Name shows "Deets" in Build Settings
- [ ] Product Name shows "Deets" in Build Settings
- [ ] Bundle Identifier is valid (no spaces, special characters)

---

## 2️⃣ Add Info.plist to Project

**Estimated time: 1 minute**

- [ ] Located `Info.plist` file (in same folder as this checklist)
- [ ] In Xcode, right-clicked "Deets" folder in navigator
- [ ] Chose "Add Files to Deets..."
- [ ] Selected `Info.plist`
- [ ] Checked "Copy items if needed"
- [ ] Checked "Deets" target is selected
- [ ] Clicked "Add"
- [ ] Verified Info.plist appears in project navigator

**Configure path:**
- [ ] Selected Deets project → Deets target → Build Settings
- [ ] Searched for "Info.plist File"
- [ ] Set to: `Deets/Info.plist` (or `Info.plist` if in root)
- [ ] Pressed ⌘S to save

**Verification:**
- [ ] Info.plist visible in Xcode project navigator
- [ ] File Inspector shows "Deets" target checked
- [ ] Build Settings shows correct Info.plist path

---

## 3️⃣ Add Assets Catalog

**Estimated time: 3 minutes**

**Option A: Create in Xcode (Recommended)**

- [ ] Right-clicked "Deets" folder in project navigator
- [ ] Created new group named "Resources"
- [ ] Right-clicked "Resources" group
- [ ] Chose "New File..." → "Asset Catalog"
- [ ] Named it "Assets" → Clicked "Create"
- [ ] Assets.xcassets now appears in Resources group

**Add AppIcon:**
- [ ] Opened Assets.xcassets in Xcode
- [ ] Right-clicked in left panel
- [ ] Chose "App Icons & Launch Images" → "New iOS App Icon"
- [ ] Named it "AppIcon"
- [ ] AppIcon now appears in asset list

**Add TealAccessible Color:**
- [ ] In Assets.xcassets, right-clicked
- [ ] Chose "Color Set"
- [ ] Named it "TealAccessible"
- [ ] Selected TealAccessible in left panel
- [ ] In Attributes Inspector (right panel):
  - [ ] For "Any Appearance": Set to RGB(0, 121, 107) or Hex #00796B
  - [ ] Clicked "+" next to Appearances → Added "Dark"
  - [ ] For "Dark Appearance": Set to RGB(35, 196, 174) or Hex #23C4AE

**Configure Asset Catalog:**
- [ ] Selected Deets project → Deets target → Build Settings
- [ ] Searched for "Asset Catalog Compiler"
- [ ] Set "App Icon Set Name" to: `AppIcon`
- [ ] Pressed ⌘S to save

**Verification:**
- [ ] Assets.xcassets exists in project navigator
- [ ] AppIcon exists inside Assets.xcassets
- [ ] TealAccessible color exists inside Assets.xcassets
- [ ] Build Settings points to "AppIcon" for app icon

---

## 4️⃣ Check for Duplicate Targets

**Estimated time: 1 minute**

- [ ] Selected Deets project in navigator
- [ ] Looked at "Targets" list in main panel
- [ ] Verified only ONE target named "Deets" exists

**If duplicates exist:**
- [ ] Selected duplicate target
- [ ] Pressed delete key
- [ ] Confirmed deletion

**Verification:**
- [ ] Only one "Deets" target in list
- [ ] Target name is "Deets" (not "Deets 2" or similar)

---

## 5️⃣ Check for Duplicate Build Phases

**Estimated time: 1 minute**

- [ ] Selected Deets target → "Build Phases" tab
- [ ] Expanded "Copy Bundle Resources"
- [ ] Scanned list for duplicate file entries
- [ ] Verified Info.plist is NOT in this list

**If duplicates exist:**
- [ ] Selected duplicate entry
- [ ] Pressed delete key (or minus button)
- [ ] Removed all duplicates

**Verification:**
- [ ] Each file appears only once in Copy Bundle Resources
- [ ] Assets.xcassets is in the list
- [ ] Info.plist is NOT in the list

---

## 6️⃣ Clean Build Folder

**Estimated time: 1 minute**

**Option A: In Xcode**
- [ ] Clicked "Product" menu
- [ ] Held Shift key
- [ ] Clicked "Clean Build Folder" (appears when holding Shift)
- [ ] Waited for completion

**Option B: Terminal**
- [ ] Opened Terminal
- [ ] Ran: `rm -rf ~/Library/Developer/Xcode/DerivedData/Deets-*`
- [ ] Command completed

**Verification:**
- [ ] Build folder cleaned successfully
- [ ] No errors appeared during clean

---

## 7️⃣ Run Verification Script

**Estimated time: 30 seconds**

- [ ] Opened Terminal
- [ ] Changed to project directory: `cd /path/to/your/project`
- [ ] Made script executable: `chmod +x verify-build-setup.sh`
- [ ] Ran script: `./verify-build-setup.sh`
- [ ] Reviewed output

**If all checks passed:**
- [ ] Script shows "All checks passed!"
- [ ] Ready to build

**If issues found:**
- [ ] Noted which files are missing
- [ ] Went back to relevant section above
- [ ] Fixed issues
- [ ] Re-ran script

---

## 8️⃣ Build the Project

**Estimated time: 1 minute**

- [ ] Opened project in Xcode
- [ ] Selected a simulator (iPhone 15, iOS 16+)
- [ ] Pressed ⌘B to build
- [ ] Build completed

**If build succeeds:**
- [ ] "Build Succeeded" message appeared
- [ ] No errors in Issue Navigator

**If build fails:**
- [ ] Noted error messages
- [ ] Checked which section above wasn't completed
- [ ] Fixed issue
- [ ] Cleaned build folder again
- [ ] Tried building again

**Verification:**
- [ ] Build completed with 0 errors
- [ ] Maybe some warnings (ignore for now)
- [ ] Issue Navigator shows green checkmark or no errors

---

## 9️⃣ Run the App

**Estimated time: 30 seconds**

- [ ] Pressed ⌘R to run
- [ ] App launched in simulator
- [ ] App icon appears (may be placeholder)
- [ ] UI displays with teal accent color

**Test key features:**
- [ ] App launches without crashing
- [ ] Main screen displays
- [ ] Tab bar appears with "Cards" and "Scan" tabs
- [ ] Teal color is visible in UI
- [ ] No immediate runtime errors

**Verification:**
- [ ] App is running in simulator
- [ ] No crash on launch
- [ ] UI matches expected design

---

## 🔟 Test Permissions (Optional but Recommended)

**Estimated time: 1 minute**

- [ ] In running app, tapped "Scan" tab
- [ ] Attempted to start camera
- [ ] Camera permission alert appeared
- [ ] Alert shows: "Deets needs camera access to scan business cards..."
- [ ] Granted permission
- [ ] Scanned or imported a test card
- [ ] Attempted to save to contacts
- [ ] Contacts permission alert appeared
- [ ] Alert shows: "Deets saves scanned business cards to your contacts..."

**Verification:**
- [ ] Both permission prompts show correct descriptions
- [ ] Camera opens after granting permission
- [ ] Contacts save works after granting permission

---

## ✨ Final Verification

- [ ] No build errors
- [ ] No runtime crashes
- [ ] App launches successfully
- [ ] UI displays correctly
- [ ] Permissions work as expected
- [ ] Ready for development!

---

## 📊 Completion Summary

**Total items completed:** _____ / 90

**Time spent:** _____ minutes

**Status:**
- [ ] ✅ All steps completed
- [ ] ⚠️ Some optional steps skipped
- [ ] ❌ Issues remaining

---

## 🆘 If You're Stuck

### Still have errors?

1. **Check which step failed:**
   - Go back to that section
   - Read it carefully
   - Complete all sub-items

2. **Review error messages:**
   - Note exact error text
   - Check which file/setting it mentions
   - Verify that file/setting is correct

3. **Read documentation:**
   - [ ] QUICK_FIX.md - Quick overview
   - [ ] BUILD_FIX_INSTRUCTIONS.md - Detailed guide
   - [ ] BUILD_SETTINGS_REFERENCE.md - Settings help
   - [ ] FILE_ORGANIZATION_GUIDE.md - File structure help

4. **Common issues:**
   - Module name not set → Go back to Step 1
   - Files not found → Go back to Steps 2-3
   - Stale build artifacts → Go back to Step 6

5. **Nuclear option:**
   - [ ] Clean build folder
   - [ ] Close Xcode completely
   - [ ] Delete DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`
   - [ ] Restart Mac (if really stuck)
   - [ ] Reopen Xcode
   - [ ] Run through checklist again

---

## 🎉 Success!

If you've reached here with all items checked and the app building:

**Congratulations!** 🎊

You've successfully fixed all build errors. Your Deets app is now ready for development.

### Next Steps for Development:

1. Add actual app icon (1024x1024 PNG)
2. Test on physical device
3. Configure code signing for your team
4. Set up CloudKit for sync
5. Continue feature development

### Keep These Files for Reference:

- This checklist for future builds
- Documentation files for team members
- Verification script for CI/CD

---

**Date completed:** _______________

**Notes:**
_____________________________________________
_____________________________________________
_____________________________________________

---

*Tip: Keep this checklist for reference when setting up new projects or helping team members!*
