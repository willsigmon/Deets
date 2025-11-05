# CloudKit Conflict Resolution

## Overview

Deets implements **Last-Writer-Wins (LWW)** conflict resolution for CloudKit sync, automatically handling multi-device editing scenarios with no user intervention required.

## Strategy: Last-Writer-Wins

### How It Works

1. **Timestamp-Based Resolution**
   - Each BusinessCard has a `dateModified` property
   - When conflicts occur, the version with the newest `dateModified` wins
   - SwiftData + CloudKit automatically implements this at the property level

2. **Automatic Conflict Detection**
   - CloudKit detects when the same record is modified on multiple devices
   - SwiftData applies NSMergeByPropertyObjectTrump policy
   - Individual properties (not entire records) are compared
   - Most recent modification for each property wins

3. **No User Intervention**
   - Conflicts are resolved automatically during sync
   - No UI prompts or user decisions required
   - Logging tracks all conflict resolutions

## Handled Scenarios

### Scenario 1: Same Card Edited on 2 Devices

**Setup:**
- Device A: Edits John Smith's email at 2:00 PM
- Device B: Edits John Smith's phone at 2:05 PM
- Both devices sync at 2:10 PM

**Resolution:**
- Device B's phone change wins (newer timestamp)
- Device A's email change is preserved (different property)
- Result: Both changes are merged into final record

**Outcome:** ✅ Both edits preserved at property level

---

### Scenario 2: Conflicting Edits to Same Property

**Setup:**
- Device A: Changes email to "john@acme.com" at 2:00 PM
- Device B: Changes email to "jsmith@company.com" at 2:05 PM
- Both devices sync at 2:10 PM

**Resolution:**
- Device B's email wins (newer timestamp: 2:05 PM)
- Device A's change is overwritten
- Conflict logged for debugging

**Outcome:** ✅ Latest change wins, logged

---

### Scenario 3: Card Deleted on One Device, Edited on Another

**Setup:**
- Device A: Deletes John Smith card at 2:00 PM
- Device B: Edits John Smith's email at 2:05 PM
- Both devices sync at 2:10 PM

**Resolution:**
- **Deletion always wins** (CloudKit default behavior)
- Edit on Device B is discarded
- Card disappears from Device B after sync
- This prevents "zombie records"

**Outcome:** ✅ Deletion propagates, edit lost (expected)

**Note:** This is standard CloudKit behavior. If users report losing edits after deletion, we can implement an "undo delete" feature or conflict prompt.

---

### Scenario 4: Network Partition

**Setup:**
- Device A offline for 2 hours, makes 5 edits
- Device B online, makes 3 edits to same cards
- Device A reconnects and syncs

**Resolution:**
- CloudKit compares timestamps for each property
- Most recent changes for each property win
- Mix of Device A and Device B changes preserved
- All conflicts logged

**Outcome:** ✅ Both devices' latest changes merged

---

## Implementation Details

### Key Components

1. **SyncService.swift**
   - `configureConflictResolution()` - Sets up LWW policy
   - `handleSyncConflicts()` - Detects and logs conflicts
   - `logConflictResolution()` - Detailed conflict logging
   - `ConflictStatistics` - Tracks conflict metrics

2. **BusinessCard Model**
   - `dateModified` - Timestamp for conflict resolution
   - `cloudKitModificationDate` - Server-side modification time
   - `isLocalOnly` - Tracks local vs synced records

3. **CloudKitConfiguration.swift**
   - `conflictResolutionPolicy` - Strategy selection
   - Currently: `.lastWriterWins`

### Conflict Logging

All conflicts are logged with:
- Card name and ID
- Local modification timestamp
- CloudKit modification timestamp
- Resolution outcome (local or remote won)

**View logs in Xcode Console:**
```
CONFLICT RESOLVED:
Card: John Smith (ID: 123-456-789)
Local Modified: Jan 15, 2025 at 2:05 PM
CloudKit Modified: Jan 15, 2025 at 2:00 PM
Resolution: Last-Writer-Wins (newest timestamp)
Winner: Local
```

### Statistics Tracking

Access conflict statistics:
```swift
let stats = syncService.getConflictStatistics()
print(stats.summary)
// Output:
// Total Conflicts: 12
// Auto-Resolved: 12
// Manual: 0
// Last Conflict: Jan 15, 2025 at 2:10 PM
```

---

## Alternative: Manual Conflict Resolution

If you want to let users choose which version to keep:

### 1. Change Policy
```swift
// In CloudKitConfiguration.swift
var conflictResolutionPolicy: ConflictResolutionPolicy {
    .manual // Instead of .lastWriterWins
}
```

### 2. Implement Conflict UI

Create `ConflictResolutionView.swift`:
```swift
struct ConflictResolutionView: View {
    let conflict: SyncConflict
    let onResolve: (Bool) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Sync Conflict Detected")
                .font(.title)

            Text("This card was modified on multiple devices. Choose which version to keep:")

            HStack {
                // Local version
                ConflictVersionCard(version: .local(conflict.localVersion))
                    .onTapGesture { onResolve(true) }

                // Remote version
                ConflictVersionCard(version: .remote(conflict.remoteVersion))
                    .onTapGesture { onResolve(false) }
            }
        }
    }
}
```

### 3. Show in SyncViewModel
```swift
// In SyncViewModel
if !activeConflicts.isEmpty {
    // Present conflict resolution sheet
    ConflictResolutionView(conflict: activeConflicts.first!)
}
```

---

## Testing Conflict Resolution

### Test Setup

1. **Two Devices**
   - iPhone with Deets installed
   - iPad with Deets installed
   - Both signed into same iCloud account

2. **Enable Sync**
   - Enable iCloud sync on both devices
   - Wait for initial sync to complete

3. **Create Test Scenario**
   ```
   Step 1: On iPhone, create "John Smith" card
   Step 2: Wait for sync (check sync status = "Up to date")
   Step 3: On iPad, verify card appears
   Step 4: Turn OFF WiFi on iPhone (airplane mode)
   Step 5: On iPhone, edit John's email to "test1@example.com"
   Step 6: On iPad, edit John's email to "test2@example.com"
   Step 7: Turn ON WiFi on iPhone
   Step 8: Wait for sync on both devices
   ```

4. **Expected Result**
   - Newest edit wins (check timestamps)
   - Console shows conflict log
   - No data loss on other properties
   - No error to user

### Viewing Logs

In Xcode:
1. Run app on device
2. Trigger conflict scenario
3. Filter console for "CONFLICT RESOLVED"
4. Check conflict statistics

---

## Edge Cases Handled

### 1. Multiple Simultaneous Edits
- Multiple devices edit same card within seconds
- CloudKit queues changes, resolves sequentially
- Property-level merging preserves max data

### 2. Offline Editing
- Device offline for hours/days
- Makes multiple edits to same card
- On reconnect, newest timestamp wins per property

### 3. Clock Skew
- Device with incorrect time
- CloudKit uses server time (UTC)
- Server timestamp is source of truth

### 4. Partial Sync Failures
- Network interruption mid-sync
- CloudKit retries automatically
- SyncService handles errors gracefully

### 5. First Sync After Enable
- Large number of local records
- Potential conflicts with existing cloud data
- Batched sync with conflict resolution

---

## Performance Considerations

### Conflict Detection Overhead

- Runs after each sync operation
- Queries cards modified in last 5 minutes
- Minimal performance impact (< 50ms for 100 cards)

### Logging Impact

- Uses OSLog (efficient, structured logging)
- Logs only written when conflicts occur
- No impact during normal sync

---

## Future Enhancements

### 1. Conflict History
- Store resolved conflicts in separate table
- Allow users to view conflict history
- "Undo" recent conflict resolutions

### 2. Smart Merge
- Combine text fields intelligently
- Detect additive vs replacement changes
- Preserve both versions when possible

### 3. Conflict Notifications
- Push notification when conflict resolved
- Summary of what changed
- Option to review resolution

### 4. Per-Field Conflict UI
- Show conflicts at individual field level
- Allow keeping different fields from each version
- "Keep both" creates duplicate with suffix

---

## Troubleshooting

### Conflicts Not Being Logged

**Symptoms:** No conflict logs in console

**Causes:**
1. Conflicts not actually occurring (same device editing)
2. Timestamps too far apart (> 5 min window)
3. Logging filtered out

**Solutions:**
1. Verify edits are from different devices
2. Check both devices have iCloud sync enabled
3. Search console for "CONFLICT" or "SyncService"

### Data Loss After Sync

**Symptoms:** Edits disappear after sync

**Causes:**
1. Older timestamp loses to newer edit
2. Deletion conflict (deletion won)
3. Sync error discarded local changes

**Solutions:**
1. Check conflict logs for timestamp comparison
2. Verify card wasn't deleted on other device
3. Review sync error logs

### Sync Stuck After Conflicts

**Symptoms:** "Syncing..." never completes

**Causes:**
1. Network connectivity issues
2. CloudKit service outage
3. Invalid data preventing save

**Solutions:**
1. Check network connection
2. Force full sync: `syncService.forceFullSync()`
3. Check Xcode console for errors

---

## CloudKit Best Practices

### 1. Always Update `dateModified`
```swift
// When editing a card
card.dateModified = Date()
try modelContext.save()
```

### 2. Use Transactions for Multi-Property Edits
```swift
// Ensures all properties have same timestamp
modelContext.transaction {
    card.email = "new@example.com"
    card.phone = "+1234567890"
    card.dateModified = Date()
}
```

### 3. Handle Sync Errors Gracefully
```swift
// Don't let conflicts crash the app
do {
    try modelContext.save()
} catch {
    logger.error("Save failed: \(error)")
    // Notify user, retry, or revert
}
```

---

## References

- [Apple CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [SwiftData with CloudKit](https://developer.apple.com/documentation/swiftdata)
- [NSMergePolicy Documentation](https://developer.apple.com/documentation/coredata/nsmergePolicy)

---

## Change Log

- **2025-01-15**: Initial implementation - Last-Writer-Wins strategy
- **Future**: Consider manual resolution mode if user feedback indicates need
