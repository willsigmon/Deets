# iCloud Sync Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         User Device                          │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                    Deets App                            │ │
│  │                                                          │ │
│  │  ┌──────────────────────────────────────────────────┐  │ │
│  │  │              UI Layer (SwiftUI)                   │  │ │
│  │  │  ┌────────────────┐    ┌────────────────────┐    │  │ │
│  │  │  │ CardListView   │    │ SyncStatusView     │    │  │ │
│  │  │  │ + Button       │◄───┤ (Settings Sheet)   │    │  │ │
│  │  │  └────────────────┘    └────────────────────┘    │  │ │
│  │  └──────────────┬────────────────────┬──────────────┘  │ │
│  │                 │                    │                  │ │
│  │  ┌──────────────▼────────────────────▼──────────────┐  │ │
│  │  │         ViewModel Layer                           │  │ │
│  │  │  ┌────────────────────────────────────────────┐  │  │ │
│  │  │  │       SyncViewModel                        │  │  │ │
│  │  │  │  - UI state (@Published)                   │  │  │ │
│  │  │  │  - User actions                            │  │  │ │
│  │  │  │  - Status formatting                       │  │  │ │
│  │  │  └─────────────────┬──────────────────────────┘  │  │ │
│  │  └────────────────────┼─────────────────────────────┘  │ │
│  │                       │                                 │ │
│  │  ┌────────────────────▼─────────────────────────────┐  │ │
│  │  │         Service Layer                             │  │ │
│  │  │  ┌──────────────────────────────────────────┐    │  │ │
│  │  │  │       SyncService                        │    │  │ │
│  │  │  │  - Sync orchestration                    │    │  │ │
│  │  │  │  - Network monitoring                    │    │  │ │
│  │  │  │  - Auto-sync scheduling                  │    │  │ │
│  │  │  │  - Error recovery                        │    │  │ │
│  │  │  └──────────────────┬───────────────────────┘    │  │ │
│  │  └─────────────────────┼──────────────────────────  │  │ │
│  │                        │                              │ │
│  │  ┌─────────────────────▼──────────────────────────┐  │ │
│  │  │      Configuration Layer                       │  │ │
│  │  │  ┌─────────────────────────────────────────┐   │  │ │
│  │  │  │  CloudKitConfiguration (Singleton)      │   │  │ │
│  │  │  │  - Global sync state                    │   │  │ │
│  │  │  │  - Container config                     │   │  │ │
│  │  │  │  - iCloud availability                  │   │  │ │
│  │  │  │  - Conflict resolution policy           │   │  │ │
│  │  │  └──────────────────┬──────────────────────┘   │  │ │
│  │  └─────────────────────┼─────────────────────────  │  │ │
│  │                        │                            │ │
│  │  ┌─────────────────────▼──────────────────────────┐  │ │
│  │  │      Persistence Layer (SwiftData)             │  │ │
│  │  │  ┌─────────────────────────────────────────┐   │  │ │
│  │  │  │  ModelContainer                         │   │  │ │
│  │  │  │  - Dynamic CloudKit config              │   │  │ │
│  │  │  │  - .none or .private database           │   │  │ │
│  │  │  └──────────────────┬──────────────────────┘   │  │ │
│  │  │  ┌─────────────────▼──────────────────────┐    │  │ │
│  │  │  │  BusinessCard Model                     │    │  │ │
│  │  │  │  - @Model annotation                    │    │  │ │
│  │  │  │  - CloudKit metadata fields             │    │  │ │
│  │  │  └─────────────────────────────────────────┘    │  │ │
│  │  └────────────────────┬───────────────────────────  │  │ │
│  └───────────────────────┼──────────────────────────────┘ │
│                          │                                 │
└──────────────────────────┼─────────────────────────────────┘
                           │
                           │ SwiftData + CloudKit
                           │ Automatic Sync
                           │
┌──────────────────────────▼─────────────────────────────────┐
│                     Apple iCloud                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         Private CloudKit Database                   │   │
│  │  - User-specific container                          │   │
│  │  - End-to-end encrypted                             │   │
│  │  - Automatic schema migration                       │   │
│  │  - Conflict resolution                              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ Cross-Device Sync
                           │
┌──────────────────────────▼─────────────────────────────────┐
│                    Other User Devices                       │
│              (iPhone, iPad, Mac with same iCloud ID)        │
└─────────────────────────────────────────────────────────────┘
```

---

## Component Responsibilities

### UI Layer

#### CardListView
- **Role**: Primary list of business cards
- **Sync Integration**: Displays SyncStatusButton in toolbar
- **Responsibilities**:
  - Render business cards from SwiftData
  - Show sync status indicator
  - Launch sync settings sheet

#### SyncStatusView
- **Role**: Comprehensive sync settings and control panel
- **Features**:
  - Enable/disable sync toggle
  - Real-time status display
  - Manual sync trigger
  - Error alerts
  - Troubleshooting tools
- **Responsibilities**:
  - User consent for iCloud sync
  - Status visualization
  - Error recovery guidance

#### SyncStatusButton
- **Role**: Compact toolbar button
- **Features**:
  - Color-coded status indicator
  - One-tap access to settings
- **Responsibilities**:
  - Quick status at-a-glance
  - Sheet presentation

---

### ViewModel Layer

#### SyncViewModel
- **Pattern**: MVVM (Model-View-ViewModel)
- **Reactive**: Combine publishers for state
- **Responsibilities**:
  1. **State Management**:
     - `@Published` properties for UI binding
     - Sync status tracking
     - Error state handling
  2. **User Actions**:
     - Toggle sync on/off
     - Trigger manual sync
     - Force full sync
     - Open iOS Settings
  3. **Presentation Logic**:
     - Format sync dates (relative time)
     - Status icon/color selection
     - Error message formatting
  4. **Coordination**:
     - Bridge between UI and Service
     - Observe configuration changes
     - Update UI on state changes

**Key Properties**:
```swift
@Published var isSyncEnabled: Bool
@Published var syncStatus: SyncStatus
@Published var isSyncing: Bool
@Published var lastSyncText: String
@Published var pendingChangesCount: Int
```

---

### Service Layer

#### SyncService
- **Pattern**: Service/Manager pattern
- **Lifecycle**: Created per ModelContext
- **Responsibilities**:
  1. **Sync Orchestration**:
     - Coordinate sync operations
     - Trigger SwiftData save to initiate CloudKit sync
     - Monitor pending changes
  2. **Scheduling**:
     - Auto-sync every 5 minutes
     - App lifecycle sync (foreground/background)
     - Network reconnection sync
  3. **Network Monitoring**:
     - Use NWPathMonitor for connectivity
     - Auto-retry on reconnection
     - Handle offline scenarios
  4. **Error Handling**:
     - Catch and classify errors
     - Map to user-friendly messages
     - Implement retry logic
  5. **Status Reporting**:
     - Update configuration state
     - Publish sync progress
     - Track last sync timestamp

**Sync Triggers**:
- Timer: Every 300 seconds (5 minutes)
- App Active: `UIApplication.didBecomeActiveNotification`
- App Background: `UIApplication.willResignActiveNotification`
- Network: NWPathMonitor reconnection
- Manual: User tap "Sync Now"

---

### Configuration Layer

#### CloudKitConfiguration
- **Pattern**: Singleton
- **Lifecycle**: App-wide, persistent
- **Responsibilities**:
  1. **Global State**:
     - Sync enabled/disabled preference
     - iCloud availability status
     - Last sync timestamp
  2. **Container Setup**:
     - CloudKit container identifier
     - Database scope (.private)
     - Conflict resolution policy
  3. **ModelConfiguration Factory**:
     - Create SwiftData ModelConfiguration
     - Toggle between .none and .private
     - Preserve local data on toggle
  4. **Availability Checking**:
     - Monitor iCloud sign-in status
     - Listen for account changes
     - Update availability in real-time
  5. **Persistence**:
     - Save preferences to UserDefaults
     - Survive app restarts

**Key Constants**:
```swift
static let containerIdentifier = "iCloud.com.deets.businesscards"
static let databaseScope = .private
```

---

### Persistence Layer

#### ModelContainer (SwiftData)
- **Framework**: SwiftData (Apple)
- **Configuration**: Dynamic based on sync preference
- **Responsibilities**:
  1. **Local Storage**:
     - SQLite database on device
     - Full CRUD operations
     - Query and filtering
  2. **CloudKit Integration**:
     - Automatic when `.private` enabled
     - Schema mirroring to CloudKit
     - Conflict resolution
     - Delta sync optimization
  3. **Configuration Modes**:
     - `.none`: Local-only, no sync
     - `.private`: Private CloudKit database sync

#### BusinessCard Model
- **Annotation**: `@Model` (SwiftData)
- **CloudKit Metadata**:
  - `@Attribute(.unique) var id: UUID` - Unique identifier for deduplication
  - `cloudKitModificationDate: Date?` - Server timestamp
  - `isLocalOnly: Bool` - Track sync status
- **Responsibilities**:
  - Define data schema
  - Support CloudKit field mapping
  - Enable conflict detection

---

## Data Flow: User Enables Sync

```
1. User Interaction
   CardListView → Tap iCloud icon → SyncStatusView sheet opens

2. Enable Sync
   SyncStatusView → Toggle "iCloud Sync" ON → SyncViewModel.toggleSync()

3. Configuration Update
   SyncViewModel → CloudKitConfiguration.enableSync()
   CloudKitConfiguration → Set isSyncEnabled = true
   CloudKitConfiguration → Save to UserDefaults

4. Container Reconfiguration
   CloudKitConfiguration → Publishes change via Combine
   DeetsApp observes → Recreates ModelContainer with .private database
   SwiftData → Establishes CloudKit connection

5. Initial Sync
   SyncService.enableSync() → Triggered
   SyncService → Save ModelContext changes
   SwiftData → Uploads local data to CloudKit
   CloudKit → Creates/updates records

6. Status Update
   CloudKit → Sync completes
   SyncService → Updates syncStatus = .idle
   SyncViewModel → Receives status update
   UI → Icon turns green, "Up to date"

7. Auto-Sync Starts
   SyncService → Starts 5-minute timer
   SyncService → Monitors network and app lifecycle
```

---

## Data Flow: Multi-Device Sync

```
Device A (iPhone)
│
├─ User adds new BusinessCard
├─ SwiftData saves to local SQLite
├─ SyncService detects change
├─ SwiftData uploads to CloudKit (automatic)
│
▼
CloudKit Private Database
│
├─ Receives new record
├─ Validates schema
├─ Stores with timestamp
├─ Notifies subscribed devices
│
▼
Device B (iPad)
│
├─ CloudKit pushes change (silent notification)
├─ SwiftData downloads new record
├─ ModelContext merges into local SQLite
├─ SwiftUI @Query automatically updates
├─ CardListView refreshes with new card
```

---

## Conflict Resolution Flow

```
Scenario: Same card edited on 2 devices offline

Device A                        Device B
│                              │
├─ Edit card (offline)         ├─ Edit card (offline)
├─ dateModified = T1           ├─ dateModified = T2 (T2 > T1)
│                              │
├─ Network reconnects          ├─ Network reconnects
├─ SwiftData syncs             ├─ SwiftData syncs
│                              │
▼                              ▼
        CloudKit Private Database
        │
        ├─ Receives 2 conflicting versions
        ├─ Compares dateModified timestamps
        ├─ T2 > T1, so Device B wins
        ├─ Resolves to Device B's version
        │
        ▼
Device A                        Device B
│                              │
├─ Receives resolved version   ├─ Receives confirmed version
├─ Local data overwritten      ├─ Local data confirmed
├─ UI updates to match server  ├─ UI stays same
```

**Policy**: Last-Writer-Wins (LWW)
- Simplest strategy
- Automatic, no user intervention
- Timestamp-based (`dateModified`)
- Future: Could add "Keep Both" or "Manual" strategies

---

## Network Monitoring Flow

```
┌──────────────────────────────────────────┐
│         NWPathMonitor (Service)           │
│  - Monitors network connectivity         │
│  - Updates every status change           │
└──────────────────┬───────────────────────┘
                   │
                   ├─ Network Available
                   │  └─> isNetworkAvailable = true
                   │      └─> Trigger sync if pending
                   │
                   └─ Network Unavailable
                      └─> isNetworkAvailable = false
                          └─> Set status = .error(.networkUnavailable)
                              └─> Queue changes for later
                              └─> UI shows "Network unavailable"
```

**Recovery**:
- Changes saved locally immediately (never lost)
- Network monitor detects reconnection
- Auto-triggers sync
- Queued changes upload
- Status updates to "Up to date"

---

## Error Handling Strategy

```
┌─────────────────────────────────────────────────────┐
│                  Error Occurs                       │
│  (Network, iCloud, Authentication, etc.)            │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│           SyncService.handleSyncError()             │
│  - Classify error type                              │
│  - Map to SyncError enum                            │
└─────────────────────┬───────────────────────────────┘
                      │
                      ├─ .iCloudUnavailable
                      │  └─> Show "Sign in to iCloud" message
                      │      └─> Provide Settings button
                      │
                      ├─ .networkUnavailable
                      │  └─> Show "Network unavailable" message
                      │      └─> Auto-retry on reconnection
                      │
                      ├─ .quotaExceeded
                      │  └─> Show "Storage full" message
                      │      └─> User must free space
                      │
                      ├─ .authenticationFailed
                      │  └─> Show "Authentication failed" message
                      │      └─> Prompt re-login
                      │
                      └─ .unknownError(message)
                         └─> Show generic error with details
                             └─> Log for debugging
                             └─> Offer "Force Full Sync"
```

**User Experience**:
- All errors show user-friendly messages
- Actionable solutions provided
- No technical jargon
- Status icon turns red
- Retry mechanisms automatic

---

## State Machine: Sync Status

```
┌─────────────────┐
│ notConfigured   │ ◄─────────────────────────┐
│ (Gray Icon)     │                           │
└────────┬────────┘                           │
         │ User enables sync                  │
         ▼                                    │
┌─────────────────┐                           │
│    syncing      │                           │
│ (Blue Icon +    │                           │
│  Spinner)       │                           │
└────────┬────────┘                           │
         │ Sync completes                     │
         ▼                                    │
┌─────────────────┐                           │
│      idle       │                           │
│ (Green Icon)    │ ◄────────────┐            │
│ "Up to date"    │              │            │
└────────┬────────┘              │            │
         │                       │            │
         ├─ Timer (5min) ────────┘            │
         ├─ Manual sync ─────────┘            │
         ├─ App active ──────────┘            │
         │                                    │
         ├─ Error occurs ───────┐             │
         ▼                      ▼             │
┌─────────────────┐    ┌──────────────────┐  │
│     error       │    │  User disables   │  │
│ (Red Icon)      │    │      sync        │──┘
│ + Error message │    └──────────────────┘
└────────┬────────┘
         │ Retry / Force sync
         └─────────────────────► Back to syncing
```

**States**:
1. **notConfigured**: Sync disabled, no CloudKit
2. **syncing**: Active sync in progress
3. **idle**: Synced, up to date
4. **error**: Sync failed, showing reason

---

## Dependency Injection Pattern

```
App Launch
│
├─ DeetsApp.init()
│  ├─ Creates CloudKitConfiguration.shared (singleton)
│  ├─ Creates SyncViewModel() (@StateObject)
│  └─ Creates ModelContainer (lazy)
│
├─ ContentView appears
│
├─ DeetsApp.setupSyncService()
│  ├─ Get mainContext from ModelContainer
│  ├─ Create SyncService(modelContext: context)
│  └─ Configure SyncViewModel with SyncService
│
└─ Environment injection
   ├─ .environmentObject(syncViewModel)
   └─ Available to all child views
```

**Benefits**:
- Clean dependency flow
- Testable (mock services)
- SwiftUI-native patterns
- Type-safe environment

---

## Performance Optimizations

### 1. Delta Sync (CloudKit Automatic)
- Only changed records uploaded
- Reduces bandwidth usage
- Faster sync times

### 2. Background Queue
- Network operations off main thread
- UI remains responsive
- NWPathMonitor uses background queue

### 3. Lazy Sync
- Only sync when needed
- 5-minute interval balances freshness vs battery
- Manual trigger for immediate sync

### 4. Caching
- SwiftData handles local caching
- No redundant downloads
- Efficient query performance

### 5. Batch Operations
- SwiftData groups changes
- Single save triggers batch upload
- Reduces API calls

---

## Security Architecture

```
┌───────────────────────────────────────────────────┐
│                  User's Device                     │
│  ┌─────────────────────────────────────────────┐  │
│  │         Local SQLite Database               │  │
│  │  - Encrypted by iOS (File Protection)      │  │
│  │  - Full device encryption (default)        │  │
│  └─────────────────────────────────────────────┘  │
└──────────────────────┬────────────────────────────┘
                       │ TLS 1.3 Encrypted Transport
                       ▼
┌───────────────────────────────────────────────────┐
│              Apple CloudKit Servers                │
│  ┌─────────────────────────────────────────────┐  │
│  │       Private Database (per user)           │  │
│  │  - End-to-end encryption                    │  │
│  │  - No Apple access to data                  │  │
│  │  - User authentication via iCloud ID        │  │
│  └─────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────┘
```

**Security Layers**:
1. **Device Encryption**: iOS File Protection
2. **Transport**: TLS 1.3 encryption
3. **Cloud Storage**: End-to-end encryption
4. **Authentication**: iCloud ID (Apple's secure auth)
5. **Authorization**: Private database (user-only access)

---

## Testing Strategy

### Unit Tests
- [ ] CloudKitConfiguration state management
- [ ] SyncService sync logic
- [ ] SyncViewModel UI state updates
- [ ] Error handling paths

### Integration Tests
- [ ] SwiftData + CloudKit integration
- [ ] Multi-device sync
- [ ] Conflict resolution
- [ ] Network error recovery

### UI Tests
- [ ] Enable/disable sync flow
- [ ] Manual sync trigger
- [ ] Error alert display
- [ ] Status icon updates

### Manual Tests
- [ ] Offline sync queueing
- [ ] Multi-device real-time sync
- [ ] iCloud account switching
- [ ] Storage quota exceeded

---

## Monitoring & Debugging

### CloudKit Dashboard
- View records: `CD_BusinessCard` table
- Check schema: Auto-generated by SwiftData
- Monitor queries: See sync activity
- Test data: Add/edit/delete records

### Xcode Console
- Filter: "CloudKit" or "Sync"
- Look for: Error logs, sync timestamps
- Network logs: NWPathMonitor status

### In-App Debugging
- Sync status view shows real-time state
- "Force Full Sync" resets state
- Error messages surface issues

---

## Future Architecture Enhancements

### 1. Push Notifications
```
CloudKit Subscription
│
├─ Silent push on remote change
├─ Wake app in background
└─> Immediate sync (no 5min wait)
```

### 2. CKSyncEngine (Advanced)
```
Replace SwiftData's automatic sync with manual:
- More control over sync timing
- Custom conflict resolution
- Selective sync (per-record control)
- Better error recovery
```

### 3. Public Database
```
Enable card sharing:
- Public CloudKit database
- Share cards via link
- Team/organization sharing
- Permissions management
```

---

**This architecture balances**:
- Simplicity (leverages SwiftData's automatic sync)
- Robustness (comprehensive error handling)
- Performance (efficient delta sync)
- Security (private, encrypted)
- Maintainability (clear separation of concerns)

---

Last Updated: 2025-11-05
Version: 1.0.0
