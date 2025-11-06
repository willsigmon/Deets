//
//  LocalizationHelper.swift
//  Deets
//
//  Type-safe localized string access with compile-time checks
//

import Foundation

/// Type-safe wrapper for accessing localized strings
/// Usage: L10n.Scan.headerTitle
enum L10n {

    // MARK: - App Branding

    enum App {
        static let name = localized("app.name")
        static let tagline = localized("app.tagline")
        static let taglineFull = localized("app.tagline.full")
    }

    // MARK: - Onboarding

    enum Onboarding {
        static let welcomeTitle = localized("onboarding.welcome.title")
        static let welcomeMessage = localized("onboarding.welcome.message")

        enum Feature1 {
            static let title = localized("onboarding.feature1.title")
            static let message = localized("onboarding.feature1.message")
        }

        enum Feature2 {
            static let title = localized("onboarding.feature2.title")
            static let message = localized("onboarding.feature2.message")
        }

        enum Feature3 {
            static let title = localized("onboarding.feature3.title")
            static let message = localized("onboarding.feature3.message")
        }

        enum Privacy {
            static let title = localized("onboarding.privacy.title")
            static let message = localized("onboarding.privacy.message")
            static let detail = localized("onboarding.privacy.detail")
        }

        enum Permissions {
            static let title = localized("onboarding.permissions.title")
            static let camera = localized("onboarding.permissions.camera")
            static let contacts = localized("onboarding.permissions.contacts")
        }

        enum Button {
            static let getStarted = localized("onboarding.button.getStarted")
            static let skip = localized("onboarding.button.skip")
            static let next = localized("onboarding.button.next")
            static let done = localized("onboarding.button.done")
        }
    }

    // MARK: - Tab Bar

    enum Tab {
        static let scan = localized("tab.scan")
        static let cards = localized("tab.cards")
        static let settings = localized("tab.settings")
    }

    // MARK: - Scan

    enum Scan {
        static let title = localized("scan.title")
        static let headerTitle = localized("scan.header.title")
        static let headerMessage = localized("scan.header.message")
        static let requirements = localized("scan.requirements")

        enum Button {
            static let start = localized("scan.button.start")
            static let cancel = localized("scan.button.cancel")
            static let retry = localized("scan.button.retry")
        }

        enum Guidance {
            static let tap = localized("scan.guidance.tap")
            static let position = localized("scan.guidance.position")
            static let hold = localized("scan.guidance.hold")
            static let lighting = localized("scan.guidance.lighting")
        }

        enum Unavailable {
            static let title = localized("scan.unavailable.title")
            static let message = localized("scan.unavailable.message")
            static let simulator = localized("scan.unavailable.simulator")
        }

        enum Permission {
            static let deniedTitle = localized("scan.permission.denied.title")
            static let deniedMessage = localized("scan.permission.denied.message")
            static let deniedButton = localized("scan.permission.denied.button")
        }

        enum Error {
            static let title = localized("scan.error.title")
            static let generic = localized("scan.error.generic")
            static let noText = localized("scan.error.noText")
            static let poorQuality = localized("scan.error.poorQuality")
            static let timeout = localized("scan.error.timeout")
        }
    }

    // MARK: - Preview

    enum Preview {
        static let title = localized("preview.title")
        static let headerTitle = localized("preview.header.title")
        static let headerMessage = localized("preview.header.message")

        enum Field {
            static let fullName = localized("preview.field.fullName")
            static let fullNameRequired = localized("preview.field.fullName.required")
            static let fullNamePlaceholder = localized("preview.field.fullName.placeholder")

            static let jobTitle = localized("preview.field.jobTitle")
            static let jobTitlePlaceholder = localized("preview.field.jobTitle.placeholder")

            static let company = localized("preview.field.company")
            static let companyPlaceholder = localized("preview.field.company.placeholder")

            static let email = localized("preview.field.email")
            static let emailPlaceholder = localized("preview.field.email.placeholder")

            static let phone = localized("preview.field.phone")
            static let phonePlaceholder = localized("preview.field.phone.placeholder")

            static let website = localized("preview.field.website")
            static let websitePlaceholder = localized("preview.field.website.placeholder")

            static let address = localized("preview.field.address")
            static let addressPlaceholder = localized("preview.field.address.placeholder")

            static let notes = localized("preview.field.notes")
            static let notesPlaceholder = localized("preview.field.notes.placeholder")
        }

        enum Validation {
            static let nameRequired = localized("preview.validation.nameRequired")
            static let emailInvalid = localized("preview.validation.emailInvalid")
            static let phoneInvalid = localized("preview.validation.phoneInvalid")
            static let websiteInvalid = localized("preview.validation.websiteInvalid")
        }

        enum Button {
            static let saveBoth = localized("preview.button.saveBoth")
            static let saveDatabaseOnly = localized("preview.button.saveDatabaseOnly")
            static let cancel = localized("preview.button.cancel")
        }

        enum Success {
            static let title = localized("preview.success.title")
            static let message = localized("preview.success.message")
            static func withContacts(_ name: String) -> String {
                String(format: localized("preview.success.withContacts"), name)
            }
            static func databaseOnly(_ name: String) -> String {
                String(format: localized("preview.success.databaseOnly"), name)
            }
        }

        enum Error {
            static let title = localized("preview.error.title")
            static let generic = localized("preview.error.generic")
            static let databaseFailed = localized("preview.error.databaseFailed")
            static let contactsFailed = localized("preview.error.contactsFailed")
            static let contactsPermissionDenied = localized("preview.error.contactsPermissionDenied")
            static let duplicate = localized("preview.error.duplicate")
        }
    }

    // MARK: - List

    enum List {
        static let title = localized("list.title")
        static let searchPlaceholder = localized("list.search.placeholder")

        enum Empty {
            static let title = localized("list.empty.title")
            static let message = localized("list.empty.message")
            static let action = localized("list.empty.action")
        }

        enum NoResults {
            static let title = localized("list.noResults.title")
            static let message = localized("list.noResults.message")
            static let action = localized("list.noResults.action")
        }

        enum Sort {
            static let title = localized("list.sort.title")
            static let dateNewest = localized("list.sort.dateNewest")
            static let dateOldest = localized("list.sort.dateOldest")
            static let nameAZ = localized("list.sort.nameAZ")
            static let nameZA = localized("list.sort.nameZA")
            static let companyAZ = localized("list.sort.companyAZ")
            static let companyZA = localized("list.sort.companyZA")
        }

        enum Filter {
            static let title = localized("list.filter.title")
            static let favorites = localized("list.filter.favorites")
            static let savedToContacts = localized("list.filter.savedToContacts")
            static let clearAll = localized("list.filter.clearAll")
        }

        enum Action {
            static let delete = localized("list.action.delete")
            static let favorite = localized("list.action.favorite")
            static let unfavorite = localized("list.action.unfavorite")
            static let share = localized("list.action.share")
            static let edit = localized("list.action.edit")
        }

        enum DeleteConfirm {
            static let title = localized("list.swipe.delete.confirm.title")
            static func message(_ name: String) -> String {
                String(format: localized("list.swipe.delete.confirm.message"), name)
            }
            static let delete = localized("list.swipe.delete.confirm.delete")
            static let cancel = localized("list.swipe.delete.confirm.cancel")
        }
    }

    // MARK: - Detail

    enum Detail {
        static let title = localized("detail.title")

        enum Button {
            static let edit = localized("detail.button.edit")
            static let share = localized("detail.button.share")
            static let delete = localized("detail.button.delete")
            static let addToContacts = localized("detail.button.addToContacts")
            static let updateInContacts = localized("detail.button.updateInContacts")
            static let viewInContacts = localized("detail.button.viewInContacts")
        }

        enum Section {
            static let basic = localized("detail.section.basic")
            static let contact = localized("detail.section.contact")
            static let location = localized("detail.section.location")
            static let notes = localized("detail.section.notes")
            static let metadata = localized("detail.section.metadata")
        }

        enum Label {
            static let name = localized("detail.label.name")
            static let jobTitle = localized("detail.label.jobTitle")
            static let company = localized("detail.label.company")
            static let email = localized("detail.label.email")
            static let phone = localized("detail.label.phone")
            static let website = localized("detail.label.website")
            static let address = localized("detail.label.address")
            static let notes = localized("detail.label.notes")
            static let dateScanned = localized("detail.label.dateScanned")
            static let favorite = localized("detail.label.favorite")
            static let savedToContacts = localized("detail.label.savedToContacts")
        }

        enum Empty {
            static let jobTitle = localized("detail.empty.jobTitle")
            static let company = localized("detail.empty.company")
            static let email = localized("detail.empty.email")
            static let phone = localized("detail.empty.phone")
            static let website = localized("detail.empty.website")
            static let address = localized("detail.empty.address")
            static let notes = localized("detail.empty.notes")
        }

        enum Action {
            static let call = localized("detail.action.call")
            static let message = localized("detail.action.message")
            static let email = localized("detail.action.email")
            static let visitWebsite = localized("detail.action.visitWebsite")
            static let openMaps = localized("detail.action.openMaps")
            static let copyEmail = localized("detail.action.copyEmail")
            static let copyPhone = localized("detail.action.copyPhone")
            static let copyWebsite = localized("detail.action.copyWebsite")
        }

        static func shareSubject(_ name: String) -> String {
            String(format: localized("detail.share.subject"), name)
        }
    }

    // MARK: - Settings

    enum Settings {
        static let title = localized("settings.title")

        enum Section {
            static let scanning = localized("settings.section.scanning")
            static let contacts = localized("settings.section.contacts")
            static let appearance = localized("settings.section.appearance")
            static let privacy = localized("settings.section.privacy")
            static let about = localized("settings.section.about")
        }

        enum Scanning {
            static let autoSave = localized("settings.scanning.autoSave")
            static let autoSaveDetail = localized("settings.scanning.autoSave.detail")
            static let haptics = localized("settings.scanning.haptics")
            static let hapticsDetail = localized("settings.scanning.haptics.detail")
            static let soundEffects = localized("settings.scanning.soundEffects")
            static let soundEffectsDetail = localized("settings.scanning.soundEffects.detail")
        }

        enum Contacts {
            static let autoSync = localized("settings.contacts.autoSync")
            static let autoSyncDetail = localized("settings.contacts.autoSync.detail")
            static let syncExisting = localized("settings.contacts.syncExisting")
            static let syncExistingDetail = localized("settings.contacts.syncExisting.detail")
            static func syncExistingButton(_ count: Int) -> String {
                String(format: localized("settings.contacts.syncExisting.button"), count)
            }
            static let syncing = localized("settings.contacts.syncExisting.syncing")
            static let syncComplete = localized("settings.contacts.syncExisting.complete")
        }

        enum Appearance {
            static let appIcon = localized("settings.appearance.appIcon")
            static let theme = localized("settings.appearance.theme")
            static let themeSystem = localized("settings.appearance.theme.system")
            static let themeLight = localized("settings.appearance.theme.light")
            static let themeDark = localized("settings.appearance.theme.dark")
        }

        enum Privacy {
            static let dataLocation = localized("settings.privacy.dataLocation")
            static let dataLocationDetail = localized("settings.privacy.dataLocation.detail")
            static let permissions = localized("settings.privacy.permissions")
            static let permissionsDetail = localized("settings.privacy.permissions.detail")
            static let policy = localized("settings.privacy.policy")
            static let deleteAll = localized("settings.privacy.deleteAll")
            static let deleteAllDetail = localized("settings.privacy.deleteAll.detail")
        }

        enum About {
            static let version = localized("settings.about.version")
            static let build = localized("settings.about.build")
            static let developer = localized("settings.about.developer")
            static let feedback = localized("settings.about.feedback")
            static let rateApp = localized("settings.about.rateApp")
            static let shareApp = localized("settings.about.shareApp")
        }

        enum DeleteAll {
            static let confirmTitle = localized("settings.deleteAll.confirm.title")
            static func confirmMessage(_ count: Int) -> String {
                String(format: localized("settings.deleteAll.confirm.message"), count)
            }
            static let delete = localized("settings.deleteAll.confirm.delete")
            static let cancel = localized("settings.deleteAll.confirm.cancel")
        }
    }

    // MARK: - Permissions

    enum Permissions {
        enum Camera {
            static let title = localized("permissions.camera.title")
            static let message = localized("permissions.camera.message")
            static let usage = localized("permissions.camera.usage")
        }

        enum Contacts {
            static let title = localized("permissions.contacts.title")
            static let message = localized("permissions.contacts.message")
            static let usage = localized("permissions.contacts.usage")
        }

        enum Button {
            static let allow = localized("permissions.button.allow")
            static let notNow = localized("permissions.button.notNow")
            static let openSettings = localized("permissions.button.openSettings")
        }
    }

    // MARK: - Accessibility

    enum Accessibility {
        static let button = localized("accessibility.button")
        static let cancel = localized("accessibility.cancel")
        static let scannerCancel = localized("accessibility.scannerCancel")
        static let scannerCancelHint = localized("accessibility.scannerCancel.hint")
        static let cardsList = localized("accessibility.cardsList")
        static let discard = localized("accessibility.discard")
        static let sortOptions = localized("accessibility.sortOptions")
        static let filterOptions = localized("accessibility.filterOptions")
        static let activeFilters = localized("accessibility.activeFilters")
    }

    // MARK: - Generic Actions

    enum Action {
        static let save = localized("action.save")
        static let cancel = localized("action.cancel")
        static let done = localized("action.done")
        static let edit = localized("action.edit")
        static let delete = localized("action.delete")
        static let share = localized("action.share")
        static let close = localized("action.close")
        static let retry = localized("action.retry")
        static let ok = localized("action.ok")
        static let yes = localized("action.yes")
        static let no = localized("action.no")
    }

    // MARK: - Generic Messages

    enum Message {
        static let loading = localized("message.loading")
        static let saving = localized("message.saving")
        static let deleting = localized("message.deleting")
        static let processing = localized("message.processing")
        static let success = localized("message.success")
        static let error = localized("message.error")
    }

    // MARK: - Date Formatting

    enum Date {
        static let today = localized("date.today")
        static let yesterday = localized("date.yesterday")
        static func daysAgo(_ days: Int) -> String {
            String(format: localized("date.daysAgo"), days)
        }
        static func weeksAgo(_ weeks: Int) -> String {
            String(format: localized("date.weeksAgo"), weeks)
        }
        static func monthsAgo(_ months: Int) -> String {
            String(format: localized("date.monthsAgo"), months)
        }
    }

    // MARK: - Counts

    enum Count {
        static func cards(_ count: Int) -> String {
            switch count {
            case 0: return localized("count.cards.zero")
            case 1: return localized("count.cards.one")
            default: return String(format: localized("count.cards.many"), count)
            }
        }

        static func results(_ count: Int) -> String {
            switch count {
            case 0: return localized("count.results.zero")
            case 1: return localized("count.results.one")
            default: return String(format: localized("count.results.many"), count)
            }
        }
    }
}

// MARK: - Helper Function

/// Internal helper to load localized strings
private func localized(_ key: String, comment: String = "") -> String {
    NSLocalizedString(key, comment: comment)
}

// MARK: - String Extension for Direct Localization

extension String {
    /// Convenience method for localizing strings directly
    /// Usage: "scan.title".localized
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    /// Localize with format arguments
    /// Usage: "preview.success.withContacts".localized(with: name)
    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}
