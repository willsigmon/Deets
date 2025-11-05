# CI/CD Setup Guide for Deets

Complete guide for setting up continuous integration and deployment for the Deets iOS app.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [GitHub Secrets Configuration](#github-secrets-configuration)
- [Fastlane Configuration](#fastlane-configuration)
- [Code Signing with Match](#code-signing-with-match)
- [Running Workflows](#running-workflows)
- [Troubleshooting](#troubleshooting)

---

## Overview

Deets uses a comprehensive CI/CD pipeline built on:

- **GitHub Actions**: Cloud-based CI/CD automation
- **Fastlane**: iOS automation tool for building, testing, and deployment
- **Match**: Code signing management (certificates and provisioning profiles)
- **SwiftLint**: Code quality and style enforcement
- **Slather**: Code coverage reporting

### Workflows

1. **iOS CI** (`.github/workflows/ios-ci.yml`)
   - Runs on every PR and push to main/develop
   - Executes SwiftLint, builds, and runs tests
   - Generates code coverage reports
   - Validates release builds

2. **iOS Release** (`.github/workflows/ios-release.yml`)
   - Triggers on version tags (e.g., `v1.0.0`)
   - Builds signed IPA
   - Deploys to TestFlight or App Store
   - Creates GitHub releases

3. **Code Quality** (`.github/workflows/code-quality.yml`)
   - Runs on PRs and weekly schedule
   - Comprehensive code analysis
   - Security scanning
   - Documentation coverage checks

---

## Prerequisites

### Local Development

1. **macOS** with Xcode 15.2+ installed
2. **Ruby** 2.7+ (check with `ruby --version`)
3. **Bundler** (install with `gem install bundler`)
4. **Homebrew** (for dependency management)
5. **Git** with SSH keys configured
6. **Apple Developer Account** (paid membership required)

### Required Tools

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install XcodeGen
brew install xcodegen

# Install SwiftLint
brew install swiftlint

# Install Bundler
gem install bundler

# Install Fastlane and dependencies
bundle install
```

---

## Initial Setup

### 1. Clone and Configure

```bash
# Clone the repository
git clone https://github.com/yourusername/Deets.git
cd Deets

# Install Ruby dependencies
bundle install

# Generate Xcode project
xcodegen generate

# Open project
open Deets.xcodeproj
```

### 2. Configure Apple Developer Portal

1. Log in to [Apple Developer Portal](https://developer.apple.com)
2. Create App ID: `com.deets.app`
3. Enable capabilities:
   - iCloud (CloudKit)
   - Push Notifications (future)
   - Camera Access
   - Contacts Access
4. Note your **Team ID** (found in Membership section)

### 3. Configure App Store Connect

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new app:
   - Name: **Deets**
   - Bundle ID: `com.deets.app`
   - SKU: `deets-ios-v1`
   - Platform: iOS
3. Create API Key:
   - Users and Access > Keys > App Store Connect API
   - Generate new key with **Admin** access
   - Download `.p8` file (only shown once!)
   - Note **Key ID** and **Issuer ID**

---

## GitHub Secrets Configuration

### Required Secrets

Navigate to **GitHub Repository → Settings → Secrets and variables → Actions**

#### 1. Apple Developer Account

```
FASTLANE_APPLE_ID
```
- Your Apple ID email address
- Example: `developer@yourcompany.com`

```
FASTLANE_TEAM_ID
```
- Your Apple Developer Team ID (10-character string)
- Example: `ABCDE12345`

#### 2. App Store Connect API

```
APP_STORE_CONNECT_API_KEY_ID
```
- Key ID from App Store Connect
- Example: `ABCD1234EF`

```
APP_STORE_CONNECT_API_ISSUER_ID
```
- Issuer ID from App Store Connect
- Example: `12345678-abcd-1234-abcd-123456789abc`

```
APP_STORE_CONNECT_API_KEY_CONTENT
```
- Base64-encoded content of your `.p8` file
- Generate with:
  ```bash
  cat AuthKey_ABCD1234EF.p8 | base64
  ```

#### 3. Code Signing (Match)

```
MATCH_GIT_URL
```
- Git repository URL for storing certificates
- Example: `https://github.com/yourcompany/certificates`
- Use a **private repository** for security

```
MATCH_PASSWORD
```
- Encryption passphrase for certificates
- Generate a strong password (20+ characters)
- Store securely (1Password, LastPass, etc.)

```
MATCH_GIT_BASIC_AUTHORIZATION
```
- Base64-encoded Git credentials for accessing certificates repo
- Generate with:
  ```bash
  echo -n "username:personal_access_token" | base64
  ```

#### 4. Optional: Notifications

```
SLACK_WEBHOOK_URL
```
- Webhook URL for Slack notifications (optional)
- Create in Slack: Apps → Incoming Webhooks

#### 5. Optional: Code Coverage

```
CODECOV_TOKEN
```
- Token from Codecov.io (optional)
- Sign up at https://codecov.io

### Setting Secrets via CLI (Alternative)

```bash
# Install GitHub CLI
brew install gh

# Authenticate
gh auth login

# Set secrets
gh secret set FASTLANE_APPLE_ID -b "developer@example.com"
gh secret set FASTLANE_TEAM_ID -b "ABCDE12345"
gh secret set APP_STORE_CONNECT_API_KEY_ID -b "ABCD1234EF"
# ... etc
```

---

## Fastlane Configuration

### 1. Update Appfile

Edit `fastlane/Appfile`:

```ruby
apple_id("your-apple-id@example.com")
itc_team_id("123456789")  # Optional: if multiple teams
team_id("ABCDE12345")
app_identifier("com.deets.app")
```

### 2. Available Lanes

```bash
# View all available lanes
bundle exec fastlane lanes

# Code quality
bundle exec fastlane lint              # Run SwiftLint
bundle exec fastlane lint_fix          # Auto-fix SwiftLint issues
bundle exec fastlane quality           # Full quality check + coverage

# Testing
bundle exec fastlane test              # Build and run tests
bundle exec fastlane build_for_testing # Build for testing only
bundle exec fastlane test_without_building  # Run tests without building

# Code signing
bundle exec fastlane sync_dev_certs    # Sync development certificates
bundle exec fastlane sync_appstore_certs # Sync App Store certificates
bundle exec fastlane register_devices  # Register new devices

# Deployment
bundle exec fastlane beta              # Upload to TestFlight
bundle exec fastlane release           # Submit to App Store

# Utilities
bundle exec fastlane screenshots       # Generate App Store screenshots
bundle exec fastlane clean             # Clean build artifacts
bundle exec fastlane setup             # Setup project after clone
```

---

## Code Signing with Match

### What is Match?

Match is Fastlane's code signing solution that stores certificates and provisioning profiles in a Git repository, ensuring all team members use the same signing assets.

### Initial Match Setup

```bash
# Initialize match (first time only)
bundle exec fastlane match init

# Answer prompts:
# - Storage mode: git
# - Git URL: https://github.com/yourcompany/certificates (private repo)
# - Set MATCH_PASSWORD environment variable

# Generate certificates and profiles
bundle exec fastlane match development
bundle exec fastlane match appstore
```

### Match Repository Structure

```
certificates/
├── certs/
│   ├── development/
│   │   └── ABCDE12345.cer
│   └── distribution/
│       └── ABCDE12345.cer
└── profiles/
    ├── development/
    │   └── AppStore_com.deets.app.mobileprovision
    └── appstore/
        └── AppStore_com.deets.app.mobileprovision
```

### Adding New Team Members

1. New developer runs:
   ```bash
   bundle exec fastlane match development
   ```
2. Enter `MATCH_PASSWORD` when prompted
3. Xcode automatically uses certificates

### Renewing Certificates

```bash
# Force renew (when expired or compromised)
bundle exec fastlane match appstore --force_for_new_devices

# Register new devices and update profiles
bundle exec fastlane register_devices
```

---

## Running Workflows

### Automatic Triggers

#### CI Workflow (Pull Requests)

```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "feat: add new feature"

# Push and create PR
git push origin feature/new-feature
# Create PR on GitHub → CI automatically runs
```

#### Release Workflow (Tags)

```bash
# Ensure you're on main branch
git checkout main
git pull origin main

# Create version tag
git tag v1.0.0
git push origin v1.0.0

# Release workflow automatically triggers
```

### Manual Triggers

#### Via GitHub UI

1. Navigate to **Actions** tab
2. Select workflow (e.g., "iOS Release")
3. Click **Run workflow**
4. Select options and click **Run**

#### Via GitHub CLI

```bash
# Trigger release workflow
gh workflow run ios-release.yml \
  -f release_type=testflight \
  -f skip_tests=false
```

### Local Testing

```bash
# Run full CI pipeline locally
bundle exec fastlane quality

# Run specific checks
bundle exec fastlane lint
bundle exec fastlane test

# Test release build (no upload)
bundle exec fastlane build_release
```

---

## Workflow Outputs

### Artifacts

Each workflow run produces downloadable artifacts:

#### iOS CI
- `test-results-*.xcresult` - Detailed test results
- `coverage.json` / `coverage.txt` - Code coverage reports
- `swiftlint-report.html` - SwiftLint analysis

#### iOS Release
- `Deets-IPA` - Signed `.ipa` file
- `Deets-dSYM` - Debug symbols for crash reporting

#### Code Quality
- `swiftlint-reports` - HTML/JSON lint reports

### Accessing Artifacts

```bash
# Via GitHub CLI
gh run list
gh run view <run-id>
gh run download <run-id>

# Via GitHub UI
Actions → Select workflow run → Artifacts section
```

---

## Troubleshooting

### Common Issues

#### 1. Code Signing Failures

**Error**: `No signing certificate found`

**Solution**:
```bash
# Ensure Match is configured
bundle exec fastlane match appstore

# Check GitHub secrets are set
gh secret list

# Verify certificate in Keychain
security find-identity -v -p codesigning
```

#### 2. Test Failures in CI

**Error**: `Tests pass locally but fail in CI`

**Solution**:
```bash
# Check simulator version matches CI
xcodebuild -showsdks

# Run tests with CI environment
IS_UNIT_TESTING=1 xcodebuild test \
  -project Deets.xcodeproj \
  -scheme Deets \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Check for test isolation issues
# - Remove dependencies between tests
# - Reset state in setUp/tearDown
```

#### 3. SwiftLint Strict Mode

**Error**: `SwiftLint warnings fail CI`

**Solution**:
```bash
# Fix auto-fixable issues
bundle exec fastlane lint_fix

# View all violations
swiftlint lint

# Disable strict mode temporarily (not recommended)
# Edit .github/workflows/ios-ci.yml
# Change: swiftlint lint --strict
# To: swiftlint lint
```

#### 4. Code Coverage Below Threshold

**Error**: `Coverage 65% below threshold 70%`

**Solution**:
```bash
# Generate local coverage report
bundle exec fastlane quality

# Open HTML report
open fastlane/coverage/index.html

# Add tests for uncovered code
# Or adjust threshold in ios-ci.yml:
# THRESHOLD=65
```

#### 5. Match Password Issues

**Error**: `Invalid Match password`

**Solution**:
```bash
# Verify password locally
export MATCH_PASSWORD="your-password"
bundle exec fastlane match development

# Update GitHub secret
gh secret set MATCH_PASSWORD

# Re-run workflow
```

#### 6. Xcode Version Mismatch

**Error**: `Selected Xcode version not available`

**Solution**:
```yaml
# Update .github/workflows/*.yml
env:
  DEVELOPER_DIR: /Applications/Xcode_15.2.app/Contents/Developer

# Check available Xcode versions on GitHub runners:
# https://github.com/actions/runner-images/blob/main/images/macos/macos-14-Readme.md
```

---

## Deployment Checklist

### Pre-Release

- [ ] All tests passing
- [ ] SwiftLint violations resolved
- [ ] Code coverage above threshold (70%)
- [ ] CHANGELOG.md updated
- [ ] Version number incremented in project.yml
- [ ] App Store metadata prepared (fastlane/metadata/)
- [ ] Screenshots captured (fastlane/screenshots/)
- [ ] Release notes written

### TestFlight Deployment

```bash
# 1. Create tag
git tag v1.0.0-beta.1
git push origin v1.0.0-beta.1

# 2. Wait for workflow to complete (~15-20 minutes)
# 3. Check TestFlight in App Store Connect
# 4. Add external testers (optional)
# 5. Send test invitation
```

### App Store Submission

```bash
# 1. Merge to main
git checkout main
git merge develop
git push origin main

# 2. Create release tag
git tag v1.0.0
git push origin v1.0.0

# 3. Manually trigger release workflow
gh workflow run ios-release.yml -f release_type=appstore

# 4. Monitor workflow progress
gh run watch

# 5. Complete submission in App Store Connect:
#    - Add metadata
#    - Upload screenshots
#    - Submit for review
```

---

## Best Practices

### Branching Strategy

```
main          - Production releases only
  └─ develop  - Integration branch
      └─ feature/* - Feature branches
      └─ bugfix/*  - Bug fixes
      └─ hotfix/*  - Production hotfixes
```

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add contact photo enrichment
fix: resolve iCloud sync conflict
docs: update CI/CD setup guide
test: add integration tests for OCR
chore: bump build number for TestFlight
```

### Version Numbering

Follow [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH
- MAJOR: Breaking changes (2.0.0)
- MINOR: New features (1.1.0)
- PATCH: Bug fixes (1.0.1)
```

### Code Coverage Goals

- **Minimum**: 70% overall coverage
- **Target**: 80% overall coverage
- **Critical paths**: 95% coverage (OCR, sync, data persistence)

---

## Performance Optimization

### CI Speedup Tips

1. **Cache Dependencies**
   ```yaml
   - uses: actions/cache@v4
     with:
       path: |
         .build
         DerivedData/SourcePackages
   ```

2. **Parallel Testing**
   ```bash
   xcodebuild test -parallel-testing-enabled YES
   ```

3. **Skip Unnecessary Steps**
   ```bash
   # Skip tests when only docs changed
   if: contains(github.event.head_commit.message, '[skip ci]')
   ```

4. **Use Matrix Builds** (if testing multiple Xcode versions)
   ```yaml
   strategy:
     matrix:
       xcode: ['15.1', '15.2']
   ```

---

## Security Considerations

### Secrets Management

- **Never commit secrets** to the repository
- Use **GitHub Secrets** for sensitive data
- Rotate **API keys** quarterly
- Use **separate keys** for development/production
- Enable **2FA** on all accounts

### Code Signing

- Store certificates in **private repository**
- Use **strong passphrase** for Match (20+ characters)
- **Revoke certificates** when team members leave
- **Review access logs** regularly

### Dependency Security

```bash
# Audit dependencies (when added)
swift package show-dependencies

# Check for vulnerabilities
bundle audit check
```

---

## Monitoring and Alerts

### GitHub Actions Notifications

1. **Repository Settings** → **Notifications**
2. Enable **Email notifications** for workflow failures
3. Configure **Slack integration** (optional)

### App Store Connect Alerts

1. **App Store Connect** → **Users and Access** → **Notifications**
2. Enable alerts for:
   - Build processing complete
   - App Store review status changes
   - Crash reports

---

## Additional Resources

### Documentation

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [GitHub Actions for iOS](https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-swift)
- [Match Code Signing](https://docs.fastlane.tools/actions/match/)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)

### Community

- [Fastlane Discussions](https://github.com/fastlane/fastlane/discussions)
- [iOS Dev Slack](https://ios-developers.slack.com)

---

## Support

For issues or questions:

1. Check [Troubleshooting](#troubleshooting) section
2. Search [GitHub Issues](https://github.com/yourusername/Deets/issues)
3. Create new issue with:
   - Workflow logs
   - Environment details
   - Steps to reproduce

---

**Last Updated**: November 2025
**Maintained By**: DevOps Team
