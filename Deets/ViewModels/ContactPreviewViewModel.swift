//
//  ContactPreviewViewModel.swift
//  Deets
//
//  ViewModel for contact preview and editing
//

import SwiftUI
import SwiftData
import Contacts
import Observation

@Observable
@MainActor
final class ContactPreviewViewModel {
    // MARK: - Published State

    /// Editable fields
    var fullName = ""
    var jobTitle = ""
    var company = ""
    var email = ""
    var phoneNumber = ""
    var website = ""
    var address = ""
    var notes = ""

    /// Validation states
    var isValidEmail = true
    var isValidPhone = true
    var isValidWebsite = true

    /// Loading and error states
    var isSaving = false
    var saveError: String?
    var showSuccessAlert = false

    /// Contact save status
    var savedToContacts = false

    // MARK: - Private Properties

    private let rawText: String
    private var modelContext: ModelContext?

    // MARK: - Dependencies

    private let hapticManager = HapticManager.shared

    // MARK: - Initialization

    init(scannedText: String) {
        self.rawText = scannedText
        parseScannedText(scannedText)
    }

    /// Set model context for saving
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Parsing

    /// Parse scanned text into contact fields
    private func parseScannedText(_ text: String) {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        // Simple parsing logic - can be enhanced with NLP later
        for (index, line) in lines.enumerated() {
            if line.contains("@") && email.isEmpty {
                email = line
            } else if line.hasPrefix("http") || line.hasPrefix("www") {
                website = line
            } else if line.matches(phonePattern) {
                phoneNumber = line
            } else if index == 0 && fullName.isEmpty {
                fullName = line
            } else if index == 1 && jobTitle.isEmpty {
                jobTitle = line
            } else if index == 2 && company.isEmpty {
                company = line
            }
        }

        validateAllFields()
    }

    // MARK: - Validation

    /// Phone number regex pattern
    private let phonePattern = #"^[\+]?[(]?[0-9]{1,4}[)]?[-\s\.]?[(]?[0-9]{1,4}[)]?[-\s\.]?[0-9]{1,9}$"#

    /// Validate email format
    func validateEmail() {
        guard !email.isEmpty else {
            isValidEmail = true
            return
        }
        let emailRegex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        isValidEmail = email.range(of: emailRegex, options: [.regularExpression, .caseInsensitive]) != nil
    }

    /// Validate phone format
    func validatePhone() {
        guard !phoneNumber.isEmpty else {
            isValidPhone = true
            return
        }
        isValidPhone = phoneNumber.range(of: phonePattern, options: .regularExpression) != nil
    }

    /// Validate website URL
    func validateWebsite() {
        guard !website.isEmpty else {
            isValidWebsite = true
            return
        }
        if let url = URL(string: website) {
            isValidWebsite = url.scheme != nil && url.host != nil
        } else {
            isValidWebsite = false
        }
    }

    /// Validate all fields
    func validateAllFields() {
        validateEmail()
        validatePhone()
        validateWebsite()
    }

    // MARK: - Computed Properties

    /// Whether the form has valid data to save
    var canSave: Bool {
        !fullName.isEmpty && isValidEmail && isValidPhone && isValidWebsite
    }

    /// Whether any field has been modified
    var hasChanges: Bool {
        !fullName.isEmpty || !email.isEmpty || !phoneNumber.isEmpty
    }

    // MARK: - Saving

    /// Save business card to SwiftData
    func saveToDatabase() async throws {
        guard let context = modelContext else {
            throw SaveError.noContext
        }

        guard canSave else {
            throw SaveError.invalidData
        }

        isSaving = true
        defer { isSaving = false }

        let card = BusinessCard(
            fullName: fullName.trimmingCharacters(in: .whitespaces),
            jobTitle: jobTitle.isEmpty ? nil : jobTitle.trimmingCharacters(in: .whitespaces),
            company: company.isEmpty ? nil : company.trimmingCharacters(in: .whitespaces),
            email: email.isEmpty ? nil : email.trimmingCharacters(in: .whitespaces),
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber.trimmingCharacters(in: .whitespaces),
            website: website.isEmpty ? nil : website.trimmingCharacters(in: .whitespaces),
            address: address.isEmpty ? nil : address.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces),
            rawText: rawText,
            savedToContacts: savedToContacts
        )

        context.insert(card)

        do {
            try context.save()
            hapticManager.saved()
            showSuccessAlert = true
        } catch {
            throw SaveError.databaseError(error)
        }
    }

    /// Save contact to iOS Contacts app
    func saveToContacts() async throws {
        let store = CNContactStore()

        // Request authorization
        let status = CNContactStore.authorizationStatus(for: .contacts)

        switch status {
        case .notDetermined:
            let granted = try await store.requestAccess(for: .contacts)
            if !granted {
                throw SaveError.contactsPermissionDenied
            }
        case .denied, .restricted:
            throw SaveError.contactsPermissionDenied
        case .authorized:
            break
        @unknown default:
            throw SaveError.contactsPermissionDenied
        }

        // Create contact
        let contact = CNMutableContact()
        contact.givenName = fullName.components(separatedBy: " ").first ?? ""
        contact.familyName = fullName.components(separatedBy: " ").dropFirst().joined(separator: " ")

        if !jobTitle.isEmpty {
            contact.jobTitle = jobTitle
        }

        if !company.isEmpty {
            contact.organizationName = company
        }

        if !email.isEmpty {
            contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: email as NSString)]
        }

        if !phoneNumber.isEmpty {
            let phone = CNPhoneNumber(stringValue: phoneNumber)
            contact.phoneNumbers = [CNLabeledValue(label: CNLabelWork, value: phone)]
        }

        if !website.isEmpty {
            contact.urlAddresses = [CNLabeledValue(label: CNLabelWork, value: website as NSString)]
        }

        if !address.isEmpty {
            let homeAddress = CNMutablePostalAddress()
            homeAddress.street = address
            contact.postalAddresses = [CNLabeledValue(label: CNLabelWork, value: homeAddress)]
        }

        if !notes.isEmpty {
            contact.note = notes
        }

        // Save to contacts
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)

        try store.execute(saveRequest)
        savedToContacts = true
        hapticManager.saved()
    }

    /// Save both to database and contacts
    func saveBoth() async {
        do {
            try await saveToContacts()
            savedToContacts = true
            try await saveToDatabase()
        } catch {
            saveError = error.localizedDescription
            hapticManager.scanError()
        }
    }

    /// Save only to database
    func saveToDatabaseOnly() async {
        do {
            try await saveToDatabase()
        } catch {
            saveError = error.localizedDescription
            hapticManager.scanError()
        }
    }
}

// MARK: - Errors

enum SaveError: LocalizedError {
    case noContext
    case invalidData
    case databaseError(Error)
    case contactsPermissionDenied

    var errorDescription: String? {
        switch self {
        case .noContext:
            return "Database context not available"
        case .invalidData:
            return "Please fix validation errors before saving"
        case .databaseError(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .contactsPermissionDenied:
            return "Contacts permission is required to save to your contacts. Please enable it in Settings."
        }
    }
}

// MARK: - String Extension

private extension String {
    func matches(_ pattern: String) -> Bool {
        range(of: pattern, options: .regularExpression) != nil
    }
}
