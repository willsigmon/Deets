# Container Recreation Bug - Fix Verification

## Problem Statement

**CRITICAL BUG**: ModelContainer was being recreated every time `CloudKitConfiguration.shared.isSyncEnabled` changed, causing all BusinessCard data to disappear when users toggled sync settings.

## Root Cause

In `DeetsApp.swift`:
- `sharedModelContainer` was a **computed property** that called `createModelContainer()` on every access
- The container configuration depended on `cloudKitConfig.isSyncEnabled` (a `@Published` property)
- When the user toggled sync, `cloudKitConfig.isSyncEnabled` changed
- This triggered a view update, which re-evaluated `body`
- The computed property returned a **NEW** container with empty data
- **Result**: All existing BusinessCard data disappeared

## Solution Implemented

### 1. Changed Container from Computed to Stored Property

**Before** (DeetsApp.swift line 26-28):
```swift
var sharedModelContainer: ModelContainer {
    createModelContainer()
}
```

**After** (DeetsApp.swift line 27-31):
```swift
private let sharedModelContainer: ModelContainer? = {
    createStableModelContainer()
}()
```

**Why This Works**:
- `let` = stored property, created ONCE on app launch
- Closure with `()` executes immediately but result is cached
- Container never recreates when `isSyncEnabled` changes

### 2. Stable Storage URL

**New Method** (DeetsApp.swift lines 108-121):
```swift
private static func stableStorageURL() -> URL {
    let appSupport = FileManager.default.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask
    ).first!

    let storeDirectory = appSupport.appendingPathComponent("Deets", isDirectory: true)

    try? FileManager.default.createDirectory(
        at: storeDirectory,
        withIntermediateDirectories: true
    )

    return storeDirectory.appendingPathComponent("BusinessCards.store")
}
```

**Storage Location**: `~/Library/Application Support/Deets/BusinessCards.store`

**Why This Works**:
- Explicit, stable file path that NEVER changes
- Independent of CloudKit sync state
- Survives app restarts, sync toggles, and upgrades

### 3. Dynamic Sync State Management

**New Method** (DeetsApp.swift lines 148-170):
```swift
private func applySyncState(_ enabled: Bool) {
    // 1. Stable storage URL (✅ stableStorageURL)
    // 2. CloudKit operations via SyncService (✅ startMonitoring/stopMonitoring)
    // 3. Container stays alive (✅ stored property, not computed)

    if enabled {
        AppLogger.sync.info("CloudKit sync enabled - data will sync to iCloud")
        syncViewModel.syncService?.startMonitoring()
    } else {
        AppLogger.sync.info("CloudKit sync disabled - data stored locally only")
        syncViewModel.syncService?.stopMonitoring()
    }
}
```

**Why This Works**:
- Container configuration has `cloudKitDatabase: .none` at creation
- CloudKit operations managed by SyncService, not container config
- Data persists in local store regardless of sync state

### 4. Added Sync Monitoring Methods

**New Methods** (SyncService.swift lines 115-130):
```swift
func startMonitoring() {
    logger.info("Starting sync monitoring")
    setupAutomaticSync()
    Task {
        await sync()
    }
}

func stopMonitoring() {
    logger.info("Stopping sync monitoring")
    syncTimer?.invalidate()
    syncTimer = nil
    syncStatus = .notConfigured
}
```

**Why This Works**:
- Decouples sync operations from container lifecycle
- Allows enabling/disabling sync without touching storage
- Sync state is ephemeral, data is permanent

## Test Scenarios (MUST VERIFY)

### Scenario 1: Toggle Sync ON with Existing Data
**Steps**:
1. Fresh install, sync OFF
2. Create 10 business cards
3. Toggle sync ON in settings

**Expected Result**:
- ✅ All 10 cards still visible
- ✅ Cards begin syncing to iCloud
- ✅ No data loss

**Verification**:
```swift
// Before toggle: 10 cards in local store
// After toggle: 10 cards in local store + syncing to CloudKit
```

### Scenario 2: Toggle Sync OFF with Synced Data
**Steps**:
1. Fresh install, enable sync
2. Create 10 cards (synced to iCloud)
3. Toggle sync OFF

**Expected Result**:
- ✅ All 10 cards still visible
- ✅ Cards remain in local store
- ✅ No data loss
- ⚠️ Cards no longer sync to iCloud

**Verification**:
```swift
// Before toggle: 10 cards in local + CloudKit
// After toggle: 10 cards in local only (CloudKit copy untouched)
```

### Scenario 3: Multiple Sync Toggles
**Steps**:
1. Fresh install, sync OFF
2. Create 10 cards
3. Toggle sync ON → verify 10 cards
4. Toggle sync OFF → verify 10 cards
5. Toggle sync ON → verify 10 cards
6. Toggle sync OFF → verify 10 cards

**Expected Result**:
- ✅ Cards persist through ALL toggles
- ✅ No data loss at any point
- ✅ Final state: 10 cards visible

### Scenario 4: Multi-Device Sync (Advanced)
**Steps**:
1. Device A: Enable sync, create 5 cards
2. Device B: Enable sync, wait for sync
3. Device B: Verify 5 cards appear
4. Device A: Toggle sync OFF
5. Device A: Create 5 more cards (total 10 local)
6. Device A: Toggle sync ON
7. Device B: Wait for sync

**Expected Result**:
- ✅ Device A: 10 cards total
- ✅ Device B: 10 cards after sync
- ✅ All cards synced correctly

### Scenario 5: Fresh Install with Sync Enabled
**Steps**:
1. Fresh install
2. Toggle sync ON immediately
3. Create 10 cards
4. Restart app

**Expected Result**:
- ✅ All 10 cards visible after restart
- ✅ Cards synced to iCloud
- ✅ Storage location stable

## Technical Details

### Container Configuration

**Before** (Dynamic, Changes with Sync State):
```swift
let cloudKitDatabase: ModelConfiguration.CloudKitDatabase =
    isSyncEnabled ? .private("iCloud.com.sharedeets.businesscards") : .none

return ModelConfiguration(
    schema: schema,
    cloudKitDatabase: cloudKitDatabase,  // ⚠️ Changes when isSyncEnabled changes
    fileProtection: .completeUnlessOpen
)
```

**After** (Stable, Independent of Sync State):
```swift
let configuration = ModelConfiguration(
    schema: schema,
    url: stableStorageURL(),              // ✅ ALWAYS the same path
    allowsSave: true,
    cloudKitDatabase: .none,              // ✅ Sync managed by SyncService
    fileProtection: .completeUnlessOpen
)
```

### Data Flow

**Before** (Data Loss):
```
User toggles sync → @Published isSyncEnabled changes
                 → View body re-evaluated
                 → sharedModelContainer computed property called
                 → createModelContainer() creates NEW container
                 → Old container destroyed
                 → ❌ ALL DATA LOST
```

**After** (Data Persists):
```
User toggles sync → @Published isSyncEnabled changes
                 → onChange handler called
                 → applySyncState(newValue) called
                 → SyncService starts/stops monitoring
                 → Container UNTOUCHED
                 → ✅ DATA PERSISTS
```

### Storage Architecture

```
Before:
┌─────────────────────────────────────┐
│ Container (Recreated on toggle)     │
├─────────────────────────────────────┤
│ Storage: Default SwiftData location │
│ CloudKit: Toggles with isSyncEnabled│
│ Lifecycle: Tied to View body        │
└─────────────────────────────────────┘
         ↓ Toggle sync
┌─────────────────────────────────────┐
│ NEW Container (Empty)               │  ❌ DATA LOST
├─────────────────────────────────────┤
│ Storage: Different location         │
│ CloudKit: New sync state            │
│ Lifecycle: Fresh start              │
└─────────────────────────────────────┘

After:
┌─────────────────────────────────────┐
│ Container (Created once)            │
├─────────────────────────────────────┤
│ Storage: Stable URL (never changes) │
│ CloudKit: Managed by SyncService    │
│ Lifecycle: App lifetime             │
└─────────────────────────────────────┘
         ↓ Toggle sync
┌─────────────────────────────────────┐
│ SAME Container (Data intact)        │  ✅ DATA PERSISTS
├─────────────────────────────────────┤
│ Storage: SAME stable URL            │
│ CloudKit: SyncService starts/stops  │
│ Lifecycle: Unchanged                │
└─────────────────────────────────────┘
```

## Migration Safeguards

### Existing Users (Important!)

Users who already have data in the old location need migration:

**Old Location** (Auto-generated by SwiftData):
```
~/Library/Application Support/default.store/
```

**New Location** (Explicit stable path):
```
~/Library/Application Support/Deets/BusinessCards.store
```

**Migration Code** (ADD IF NEEDED):
```swift
private static func migrateExistingData() {
    let fileManager = FileManager.default
    let oldLocation = /* SwiftData default location */
    let newLocation = stableStorageURL()

    if fileManager.fileExists(atPath: oldLocation.path) &&
       !fileManager.fileExists(atPath: newLocation.path) {
        try? fileManager.moveItem(at: oldLocation, to: newLocation)
        AppLogger.database.info("Migrated existing data to stable location")
    }
}
```

**Note**: SwiftData may handle this automatically via `url:` parameter. Test with existing data!

## Verification Checklist

Before marking this bug as fixed, verify:

- [ ] Run Scenario 1: Toggle ON doesn't lose data
- [ ] Run Scenario 2: Toggle OFF doesn't lose data
- [ ] Run Scenario 3: Multiple toggles preserve data
- [ ] Run Scenario 4: Multi-device sync works correctly
- [ ] Run Scenario 5: Fresh install with sync enabled works
- [ ] Verify storage location is stable: `~/Library/Application Support/Deets/BusinessCards.store`
- [ ] Verify container is created only ONCE (add logging)
- [ ] Test with 50+ cards to ensure performance is acceptable
- [ ] Test app restart with sync ON
- [ ] Test app restart with sync OFF
- [ ] Verify existing users' data migrates correctly (if applicable)

## Success Criteria

Fix is complete when:

1. ✅ Container is never recreated during sync toggles
2. ✅ Data persists across all sync state changes
3. ✅ Storage location is stable and explicit
4. ✅ All test scenarios pass
5. ✅ No regressions in sync functionality
6. ✅ Logging confirms single container creation

## Files Modified

1. `/Volumes/Ext-code/GitHub Repos/Deets/Deets/App/DeetsApp.swift`
   - Changed `sharedModelContainer` from computed to stored property
   - Added `stableStorageURL()` method
   - Added `handleSyncToggle()` method
   - Added `applySyncState()` method
   - Added `.onChange(of: cloudKitConfig.isSyncEnabled)` handler

2. `/Volumes/Ext-code/GitHub Repos/Deets/Deets/Services/SyncService.swift`
   - Added `startMonitoring()` method
   - Added `stopMonitoring()` method

## Next Steps

1. **Build and test** on simulator
2. **Run all test scenarios** listed above
3. **Add unit tests** for container lifecycle
4. **Add integration tests** for sync toggles
5. **Test with existing user data** (migration)
6. **Monitor CloudKit dashboard** for sync activity
7. **Add telemetry** to track container recreation (should be ZERO)

## Related Issues

- CloudKit sync configuration (CloudKitConfiguration.swift)
- SwiftData container lifecycle
- State management in SwiftUI App struct
- Data persistence across configuration changes
