# Deets - Documentation Index

**Complete guide to all project documentation**

Last Updated: 2025-11-05 | Version: 1.0.0

---

## Quick Navigation

| Document | Purpose | Audience |
|----------|---------|----------|
| [DEPLOYMENT_SUMMARY.md](#deployment-summary) | Architecture foundation complete | All team members |
| [architecture.md](#architecture) | Complete system architecture | Engineers, Architects |
| [pipeline.md](#pipeline) | Data flow pipeline details | Engineers |
| [PROJECT_STRUCTURE.md](#project-structure) | Folder hierarchy guide | All developers |
| [QUICK_REFERENCE.md](#quick-reference) | Fast lookup for common tasks | All developers |
| [privacy-policy.md](#privacy-policy) | User-facing privacy policy | Legal, Users |
| [context.yaml](#agent-context) | Agent coordination | AI agents |

---

## Core Architecture Documents

### DEPLOYMENT_SUMMARY.md
**Status**: ✅ Complete
**Size**: 12KB
**Updated**: 2025-11-05

**What's Inside:**
- Mission summary: Architecture foundation complete
- All deliverables (9 files created)
- Architecture highlights (MVVM, data flow)
- Technology stack (100% Apple frameworks)
- 8-week implementation roadmap
- 7 specialized agent roles
- Performance targets
- Success metrics
- Risk mitigation

**When to Read:**
- Starting work on the project
- Onboarding new team members
- Understanding project scope
- Reviewing architecture decisions

**Key Takeaway**: Complete blueprint for building Deets from scratch

---

### architecture.md
**Status**: ✅ Complete
**Size**: 21KB
**Updated**: 2025-11-05

**What's Inside:**
- Executive summary (privacy-first, offline-first)
- MVVM architecture pattern explained
- Layer-by-layer breakdown:
  - Views (SwiftUI)
  - ViewModels (state management)
  - Services (OCR, Database, Photo, Export)
  - Models (SwiftData)
- Data flow pipeline (7 stages)
- Privacy-first architecture
- Offline-first strategy
- Performance considerations
- Testing strategy (unit, UI, integration)
- Error handling (typed errors)
- Security considerations
- Scalability planning
- Future roadmap (v1.x, v2.0, v3.0)

**When to Read:**
- Implementing any architectural layer
- Making design decisions
- Writing tests
- Planning features
- Code reviews

**Key Sections:**
- Layer Breakdown (lines 40-250)
- Data Flow Pipeline (lines 251-300)
- Privacy-First Architecture (lines 301-350)
- Testing Strategy (lines 400-450)

**Key Takeaway**: Comprehensive system design with privacy and performance at the core

---

### pipeline.md
**Status**: ✅ Complete
**Size**: 30KB
**Updated**: 2025-11-05

**What's Inside:**
- Complete data flow pipeline (Capture → Export)
- Stage-by-stage breakdown:
  1. Capture (VisionKit camera)
  2. Preprocessing (image optimization)
  3. OCR (text recognition)
  4. Parsing (field extraction)
  5. Validation (user review)
  6. Persistence (SwiftData save)
  7. Export (Contacts/VCF/CSV)
- OCR algorithms and heuristics
- Parsing logic (email, phone, address, name, company)
- Confidence scoring system
- Error recovery strategies
- Performance benchmarks
- Privacy checkpoints
- Future enhancements (batch, QR, ML)

**When to Read:**
- Implementing OCR service
- Building parsing algorithms
- Understanding data flow
- Optimizing performance
- Debugging pipeline issues

**Key Sections:**
- OCR & Parsing (lines 100-250)
- Validation & User Review (lines 251-300)
- Export Phase (lines 400-500)
- Performance Benchmarks (lines 600-650)

**Key Takeaway**: Detailed implementation guide for entire data pipeline

---

### PROJECT_STRUCTURE.md
**Status**: ✅ Complete
**Size**: 16KB
**Updated**: 2025-11-05

**What's Inside:**
- Complete folder hierarchy (visual tree)
- Every folder explained
- Key file descriptions
- File naming conventions
- Import organization
- Git ignore patterns
- Future structure (v2.0+, Android)
- Cross-platform planning

**When to Read:**
- Creating new files
- Organizing code
- Navigating codebase
- Onboarding new developers
- Planning new features

**Key Sections:**
- Root Directory (lines 10-100)
- Views Layer (lines 101-150)
- Services Layer (lines 151-200)
- File Naming Conventions (lines 300-350)

**Key Takeaway**: Never get lost in the codebase - every file has its place

---

### QUICK_REFERENCE.md
**Status**: ✅ Complete
**Size**: 6KB
**Updated**: 2025-11-05

**What's Inside:**
- Fast lookup for common tasks
- Code snippets for:
  - Creating ViewModels
  - Implementing Services
  - SwiftData queries
  - Error handling
  - Testing patterns
- Command reference
- Common workflows

**When to Read:**
- Starting a new feature
- Need a quick example
- Can't remember syntax
- Writing tests

**Key Takeaway**: Cheat sheet for daily development

---

## Configuration Documentation

### FeatureFlags.swift
**Status**: ✅ Complete
**Size**: 11KB
**Location**: `/Config/FeatureFlags.swift`

**What's Inside:**
- 20+ feature flags
- Core features (scanning, OCR, export)
- Privacy & sync (iCloud, photo library)
- Advanced features (batch, QR, ML)
- Experimental (LinkedIn, CRM)
- UI enhancements (dark mode, haptics)
- Debug features (overlay, mock data)
- UserDefaults persistence
- SwiftUI environment integration

**When to Use:**
- Gradual feature rollout
- A/B testing
- Disable features in production
- Debug mode toggles

**Example:**
```swift
@Environment(\.featureFlags) var flags

if flags.batchScanningEnabled {
    // Show batch scanning UI
}
```

---

### Constants.swift
**Status**: ✅ Complete
**Size**: 14KB
**Location**: `/Config/Constants.swift`

**What's Inside:**
- 150+ app-wide constants
- App info (name, version, URLs)
- File paths (photos, thumbnails, exports)
- Image processing (size, compression)
- OCR configuration (languages, confidence)
- Validation patterns (email, phone, URL)
- UI dimensions (padding, radius, animations)
- Colors and typography
- Performance settings
- Compiled regex patterns

**When to Use:**
- Need a constant value
- Avoid magic numbers
- Consistent configuration
- Validation logic

**Example:**
```swift
import Constants

let maxSize = Constants.ImageProcessing.maxImageSize
let primaryColor = Constants.Colors.primary
let minConfidence = Constants.OCR.minConfidence
```

---

## Privacy Documentation

### privacy-policy.md
**Status**: ✅ Complete
**Size**: 11KB
**Location**: `/Privacy/privacy-policy.md`

**What's Inside:**
- User-facing privacy policy
- GDPR and CCPA compliant
- App Store ready
- Sections:
  - Our Commitment to Privacy
  - What Data We Collect
  - How We Use Your Data
  - How We Process Your Data (on-device)
  - Data Sharing and Exports
  - Permissions We Request
  - iCloud Sync (Optional)
  - Data Security
  - Data Retention and Deletion
  - Third-Party Services (none)
  - Children's Privacy
  - Changes to This Policy
  - Your Rights
  - Contact Us
  - Legal (CCPA, GDPR)

**When to Use:**
- App Store submission
- User privacy questions
- Legal review
- Compliance audit

**Key Guarantee**: "We don't collect, store, or transmit your data to our servers"

---

## Agent Coordination

### context.yaml
**Status**: ✅ Complete
**Size**: 8KB
**Location**: `/system/context.yaml`

**What's Inside:**
- Project mission and principles
- Architecture overview
- Technology stack
- Data flow pipeline
- Permissions required
- Folder structure
- Coding standards
- Agent roles (7 specialized):
  1. ORION (Chief Architect) ✅ Complete
  2. UI Builder (SwiftUI)
  3. Business Logic Engineer
  4. Data Engineer (SwiftData)
  5. OCR Specialist (VisionKit)
  6. QA Engineer (Testing)
  7. Privacy Officer (Security)
- Development workflows
- Testing strategy
- Success metrics
- Known limitations
- Future roadmap

**When to Use:**
- AI agent coordination
- Understanding project mission
- Onboarding agents
- Checking coding standards
- Reviewing workflows

**Key Section**: Agent Roles (lines 200-280)

---

## Additional Documentation

### Root Directory Markdown Files

| File | Purpose | Status |
|------|---------|--------|
| README.md | Project overview | ✅ Exists |
| QUICKSTART.md | Getting started guide | ✅ Exists |
| OCR_IMPLEMENTATION.md | OCR details | ✅ Exists |
| BUILD_GUIDE.md | Build instructions | ✅ Exists |
| INTEGRATION_GUIDE.md | Integration steps | ✅ Exists |
| PHASE1_SUMMARY.md | Phase 1 complete | ✅ Exists |
| CONTACTS_INTEGRATION_COMPLETE.md | Contacts work done | ✅ Exists |
| IVY_DELIVERY_SUMMARY.md | Ivy agent summary | ✅ Exists |
| NOVA_DELIVERY.md | Nova agent summary | ✅ Exists |
| FILE_MANIFEST.md | File listing | ✅ Exists |

---

## Documentation Roadmap

### v1.0 (Current - Complete)
- ✅ Architecture design
- ✅ Data pipeline
- ✅ Project structure
- ✅ Privacy policy
- ✅ Feature flags
- ✅ Constants
- ✅ Agent coordination

### v1.1 (Future)
- [ ] API documentation (generated from code)
- [ ] User guide (end-user facing)
- [ ] Contribution guide
- [ ] Code style guide (SwiftLint config)
- [ ] Release notes template
- [ ] Change log

### v2.0 (Future)
- [ ] Architecture decision records (ADRs)
- [ ] Performance optimization guide
- [ ] Internationalization guide
- [ ] Android migration guide
- [ ] Web app architecture

---

## How to Use This Index

### For New Team Members
1. Start with [DEPLOYMENT_SUMMARY.md](#deployment-summary)
2. Read [architecture.md](#architecture)
3. Browse [PROJECT_STRUCTURE.md](#project-structure)
4. Bookmark [QUICK_REFERENCE.md](#quick-reference)
5. Check [context.yaml](#agent-context) for your role

### For Developers
- **Starting a feature**: architecture.md → pipeline.md → QUICK_REFERENCE.md
- **Need a constant**: Constants.swift
- **Toggle a feature**: FeatureFlags.swift
- **File location**: PROJECT_STRUCTURE.md
- **Data flow**: pipeline.md

### For Architects
- **System design**: architecture.md
- **Performance**: pipeline.md (benchmarks section)
- **Future planning**: DEPLOYMENT_SUMMARY.md (roadmap)
- **Scalability**: architecture.md (scalability section)

### For QA Engineers
- **Testing strategy**: architecture.md (testing section)
- **Test coverage**: DEPLOYMENT_SUMMARY.md (metrics)
- **Error scenarios**: pipeline.md (error recovery)

### For Privacy/Legal
- **Privacy policy**: privacy-policy.md
- **Compliance**: architecture.md (privacy section)
- **Data handling**: pipeline.md (privacy checkpoints)

---

## Documentation Standards

### Markdown Files
- Use ATX headers (# ## ###)
- Code blocks with language tags
- Tables for comparisons
- Emoji sparingly (only in summaries)
- Line length: ~80-120 characters
- Update "Last Updated" date when changed

### Code Documentation
- Inline docs for all public APIs
- Examples in doc comments
- Use MARK: comments for organization
- Protocol docs explain "why" not just "what"

### Commit Messages
```
feat: Add OCR confidence scoring
fix: Resolve duplicate detection bug
docs: Update architecture.md with new service
test: Add unit tests for ContactParser
refactor: Extract validation logic to service
```

---

## Quick Links

**Architecture**:
- [DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md)
- [architecture.md](architecture.md)
- [pipeline.md](pipeline.md)

**Structure**:
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

**Configuration**:
- [FeatureFlags.swift](../Config/FeatureFlags.swift)
- [Constants.swift](../Config/Constants.swift)

**Privacy**:
- [privacy-policy.md](../Privacy/privacy-policy.md)

**Agent Coordination**:
- [context.yaml](../system/context.yaml)

**Existing Docs**:
- [README.md](../README.md)
- [QUICKSTART.md](../QUICKSTART.md)
- [OCR_IMPLEMENTATION.md](../OCR_IMPLEMENTATION.md)
- [BUILD_GUIDE.md](../BUILD_GUIDE.md)

---

## Need Help?

**Can't find what you need?**
1. Search all docs: `grep -r "your search term" Docs/`
2. Check INDEX.md (this file) for navigation
3. Review context.yaml for agent-specific guidance
4. Ask in project discussions

**Found an error or gap?**
- Update the relevant doc
- Update "Last Updated" date
- Commit with `docs:` prefix

---

**Total Documentation**: 15+ files
**Total Size**: ~150KB of comprehensive docs
**Coverage**: 100% of v1.0 architecture

**Status**: Documentation foundation complete. Ready for implementation phase.

---

*This index is the entry point to all Deets documentation.*
*Bookmark this page for fast navigation.*

**Built by ORION, Chief Architect**
**Last Updated**: 2025-11-05
