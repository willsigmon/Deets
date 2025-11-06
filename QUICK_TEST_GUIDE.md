# Container Fix - Quick Test Guide

## 🚨 THE BUG
When user toggles sync ON/OFF, all BusinessCard data disappears.

## ✅ THE FIX
Container is now created ONCE with stable storage. Sync managed separately.

---

## 🧪 Quick Test (2 minutes)

### Test 1: Toggle ON
1. Launch app (sync OFF)
2. Create 3 cards: "Alice", "Bob", "Carol"
3. Go to Settings → Toggle sync ON
4. **VERIFY**: All 3 cards still visible ✅

### Test 2: Toggle OFF
1. (Continuing from Test 1)
2. Go to Settings → Toggle sync OFF
3. **VERIFY**: All 3 cards still visible ✅

### Test 3: Multiple Toggles
1. (Continuing from Test 2)
2. Toggle sync: ON → OFF → ON → OFF
3. **VERIFY**: All 3 cards still visible after each toggle ✅

---

## 🔍 Look For These Logs

### App Launch (Should see ONCE):
```
🔧 [DeetsApp] Creating ModelContainer
💾 [DeetsApp] Storage URL: .../Deets/BusinessCards.store
```

### Toggle Sync ON:
```
🔄 [DeetsApp] Sync toggled: false → true
📱 [SyncService] Starting sync monitoring
```

### Toggle Sync OFF:
```
🔄 [DeetsApp] Sync toggled: true → false
📱 [SyncService] Stopping sync monitoring
```

### ❌ BAD SIGN:
If you see "Creating ModelContainer" MORE THAN ONCE during toggles → BUG NOT FIXED

---

## 📁 Storage Location

Container stored at:
```
~/Library/Application Support/Deets/BusinessCards.store
```

Check in Simulator:
```bash
# Get simulator path
xcrun simctl get_app_container booted com.sharedeets.app data

# Then check
ls -la "$(xcrun simctl get_app_container booted com.sharedeets.app data)/Library/Application Support/Deets/"
```

Should see:
```
BusinessCards.store
BusinessCards.store-shm
BusinessCards.store-wal
```

---

## 🐛 Debugging

### Add Debug Logging

In `DeetsApp.swift` line 31, add:
```swift
private let sharedModelContainer: ModelContainer? = {
    print("🔧 [DeetsApp] Creating ModelContainer at \(Date())")
    let container = createStableModelContainer()
    print("🔧 [DeetsApp] Container created: \(container != nil)")
    return container
}()
```

In `DeetsApp.swift` line 143, add:
```swift
private func handleSyncToggle(from oldValue: Bool, to newValue: Bool) {
    guard oldValue != newValue else { return }
    print("🔄 [DeetsApp] Sync toggled: \(oldValue) → \(newValue)")
    AppLogger.sync.info("Sync toggled from \(oldValue) to \(newValue)")
    applySyncState(newValue)
}
```

### Console Filter

In Xcode Console, filter by:
- `DeetsApp` - See container creation
- `SyncService` - See sync operations
- `🔧` - See debug markers

---

## ✅ Success Criteria

1. Container created ONCE per app launch
2. Sync toggles do NOT recreate container
3. All cards persist through toggles
4. Stable storage location used
5. Sync operations work correctly

---

## 🆘 If Test Fails

### Cards Disappear on Toggle
→ Container still being recreated
→ Check: Is `sharedModelContainer` a `let` or `var`?
→ Check: Look for "Creating ModelContainer" logs

### Sync Doesn't Work
→ SyncService not starting correctly
→ Check: Are `startMonitoring()`/`stopMonitoring()` called?
→ Check: CloudKit logs in Console

### App Crashes
→ Container creation failed
→ Check: Error logs in `createStableModelContainer()`
→ Check: Storage directory permissions

---

## 📊 Test Results Template

```
✅ Test 1: Toggle ON - Cards persist
✅ Test 2: Toggle OFF - Cards persist
✅ Test 3: Multiple toggles - Cards persist
✅ Container created once: [timestamp]
✅ Storage location stable: ~/Library/.../Deets/
✅ Sync operations work correctly

OR

❌ Test X failed: [description]
   - Expected: [what should happen]
   - Actual: [what happened]
   - Logs: [paste relevant logs]
```

---

## 🔄 Quick Reset

To start fresh:
```bash
# Delete app from simulator
xcrun simctl uninstall booted com.sharedeets.app

# Clean build
cd "/Volumes/Ext-code/GitHub Repos/Deets"
xcodebuild clean

# Rebuild and install
```

---

## 📝 Key Files

- `Deets/App/DeetsApp.swift` - Main fix
- `Deets/Services/SyncService.swift` - Monitoring methods
- `CONTAINER_FIX_SUMMARY.md` - Detailed explanation
- `CONTAINER_FIX_VERIFICATION.md` - Full test scenarios

---

**Remember**: The fix separates STORAGE (container) from SYNC (CloudKit). Storage is permanent and stable. Sync is optional and dynamic.
