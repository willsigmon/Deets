//
//  ContactsService.swift
//  Deets
//
//  Manages Apple Contacts framework integration
//  Handles permissions, duplicate detection, and contact saving
//

import Foundation
import Contacts
import SwiftUI

/// Manages all interactions with the Apple Contacts framework
@MainActor
class ContactsService: ObservableObject {
    // MARK: - Published Properties

    @Published var authorizationStatus: CNAuthorizationStatus = .notDetermined
    @Published var lastError: ContactsError?

    // MARK: - Properties

    private let store = CNContactStore()

    // MARK: - Initialization

    init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    /// Check current authorization status
    func checkAuthorizationStatus() {
        authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    }

    /// Request access to contacts
    func requestAccess() async throws {
        do {
            let granted = try await store.requestAccess(for: .contacts)

            if granted {
                authorizationStatus = .authorized
            } else {
                authorizationStatus = .denied
                throw ContactsError.accessDenied
            }
        } catch {
            authorizationStatus = .denied
            throw ContactsError.accessDenied
        }
    }

    /// Ensure we have permission (request if needed)
    private func ensureAuthorized() async throws {
        checkAuthorizationStatus()

        switch authorizationStatus {
        case .authorized:
            return
        case .notDetermined:
            try await requestAccess()
        case .denied, .restricted:
            throw ContactsError.accessDenied
        @unknown default:
            throw ContactsError.accessDenied
        }
    }

    // MARK: - Contact Saving

    /// Save a parsed contact to Apple Contacts
    /// - Parameters:
    ///   - parsedContact: The parsed contact data
    ///   - checkDuplicates: Whether to check for duplicates before saving
    /// - Returns: The saved contact identifier
    @discardableResult
    func saveContact(_ parsedContact: ParsedContact, checkDuplicates: Bool = true) async throws -> String {
        try await ensureAuthorized()

        // Validate minimum data
        guard parsedContact.isValidForSaving else {
            throw ContactsError.insufficientData
        }

        // Check for duplicates if requested
        if checkDuplicates {
            if let duplicates = try await findDuplicates(for: parsedContact), !duplicates.isEmpty {
                throw ContactsError.duplicateFound(contacts: duplicates)
            }
        }

        // Convert to CNMutableContact
        let contact = parsedContact.toCNMutableContact()

        // Create save request
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)

        // Execute save
        do {
            try store.execute(saveRequest)
            return contact.identifier
        } catch {
            throw ContactsError.saveFailed(underlying: error)
        }
    }

    /// Save multiple contacts in batch
    func saveContacts(_ parsedContacts: [ParsedContact], checkDuplicates: Bool = true) async throws -> [String] {
        try await ensureAuthorized()

        var savedIdentifiers: [String] = []
        var errors: [ContactsError] = []

        for parsedContact in parsedContacts {
            do {
                let identifier = try await saveContact(parsedContact, checkDuplicates: checkDuplicates)
                savedIdentifiers.append(identifier)
            } catch let error as ContactsError {
                errors.append(error)
            }
        }

        // If all failed, throw aggregate error
        if savedIdentifiers.isEmpty && !errors.isEmpty {
            throw ContactsError.batchSaveFailed(errors: errors)
        }

        return savedIdentifiers
    }

    /// Update an existing contact with new data
    func updateContact(identifier: String, with parsedContact: ParsedContact) async throws {
        try await ensureAuthorized()

        // Fetch existing contact
        let keysToFetch = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
        ] as [CNKeyDescriptor]

        guard let existingContact = try? store.unifiedContact(
            withIdentifier: identifier,
            keysToFetch: keysToFetch
        ) else {
            throw ContactsError.contactNotFound
        }

        // Convert to mutable
        guard let mutableContact = existingContact.mutableCopy() as? CNMutableContact else {
            AppLogger.contacts.error("Failed to create mutable copy of existing contact")
            throw ContactsError.updateFailed(underlying: NSError(
                domain: "com.deets.contacts",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to create mutable contact copy"]
            ))
        }

        // Merge new data
        let newContact = parsedContact.toCNMutableContact()

        // Merge fields (keeping existing if new is empty)
        if !newContact.givenName.isEmpty {
            mutableContact.givenName = newContact.givenName
        }
        if !newContact.familyName.isEmpty {
            mutableContact.familyName = newContact.familyName
        }
        if !newContact.organizationName.isEmpty {
            mutableContact.organizationName = newContact.organizationName
        }
        if !newContact.jobTitle.isEmpty {
            mutableContact.jobTitle = newContact.jobTitle
        }

        // Merge phone numbers (add new ones)
        var allPhones = mutableContact.phoneNumbers
        for newPhone in newContact.phoneNumbers {
            // Check if phone doesn't already exist
            let phoneExists = allPhones.contains { existing in
                existing.value.stringValue == newPhone.value.stringValue
            }
            if !phoneExists {
                allPhones.append(newPhone)
            }
        }
        mutableContact.phoneNumbers = allPhones

        // Merge emails
        var allEmails = mutableContact.emailAddresses
        for newEmail in newContact.emailAddresses {
            let emailExists = allEmails.contains { existing in
                existing.value as String == newEmail.value as String
            }
            if !emailExists {
                allEmails.append(newEmail)
            }
        }
        mutableContact.emailAddresses = allEmails

        // Save update
        let saveRequest = CNSaveRequest()
        saveRequest.update(mutableContact)

        do {
            try store.execute(saveRequest)
        } catch {
            throw ContactsError.saveFailed(underlying: error)
        }
    }

    // MARK: - Duplicate Detection

    /// Find potential duplicate contacts
    func findDuplicates(for parsedContact: ParsedContact) async throws -> [CNContact]? {
        try await ensureAuthorized()

        var potentialDuplicates: [CNContact] = []

        // Strategy 1: Search by name
        if let givenName = parsedContact.givenName,
           let familyName = parsedContact.familyName {
            let nameMatches = try await searchContacts(
                givenName: givenName,
                familyName: familyName
            )
            potentialDuplicates.append(contentsOf: nameMatches)
        }

        // Strategy 2: Search by phone number
        for phone in parsedContact.phoneNumbers where phone.isValid {
            let phoneMatches = try await searchContacts(phoneNumber: phone.number)
            potentialDuplicates.append(contentsOf: phoneMatches)
        }

        // Strategy 3: Search by email
        for email in parsedContact.emailAddresses where email.isValid {
            let emailMatches = try await searchContacts(email: email.address)
            potentialDuplicates.append(contentsOf: emailMatches)
        }

        // Remove duplicates from results (same contact found multiple ways)
        let uniqueDuplicates = Array(Set(potentialDuplicates.map { $0.identifier }))
            .compactMap { identifier in
                potentialDuplicates.first { $0.identifier == identifier }
            }

        return uniqueDuplicates.isEmpty ? nil : uniqueDuplicates
    }

    /// Search contacts by name
    private func searchContacts(givenName: String, familyName: String) async throws -> [CNContact] {
        let predicate = CNContact.predicateForContacts(matchingName: "\(givenName) \(familyName)")
        let keysToFetch = [
            CNContactIdentifierKey,
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactOrganizationNameKey
        ] as [CNKeyDescriptor]

        do {
            return try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        } catch {
            return []
        }
    }

    /// Search contacts by phone number
    private func searchContacts(phoneNumber: String) async throws -> [CNContact] {
        // Normalize phone for comparison
        let normalizedPhone = phoneNumber.filter { $0.isNumber }

        let keysToFetch = [
            CNContactIdentifierKey,
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
        ] as [CNKeyDescriptor]

        // Fetch all contacts (there's no direct phone predicate)
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        var matches: [CNContact] = []

        try store.enumerateContacts(with: fetchRequest) { contact, stop in
            for phone in contact.phoneNumbers {
                let contactPhone = phone.value.stringValue.filter { $0.isNumber }
                if contactPhone == normalizedPhone {
                    matches.append(contact)
                    return
                }
            }
        }

        return matches
    }

    /// Search contacts by email
    private func searchContacts(email: String) async throws -> [CNContact] {
        let normalizedEmail = email.lowercased()

        let keysToFetch = [
            CNContactIdentifierKey,
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
        ] as [CNKeyDescriptor]

        // Fetch all contacts (there's no direct email predicate)
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        var matches: [CNContact] = []

        try store.enumerateContacts(with: fetchRequest) { contact, stop in
            for emailAddress in contact.emailAddresses {
                let contactEmail = (emailAddress.value as String).lowercased()
                if contactEmail == normalizedEmail {
                    matches.append(contact)
                    return
                }
            }
        }

        return matches
    }

    // MARK: - Contact Fetching

    /// Fetch a contact by identifier
    func fetchContact(identifier: String) async throws -> CNContact {
        try await ensureAuthorized()

        let keysToFetch = [
            CNContactIdentifierKey,
            CNContactNamePrefixKey,
            CNContactGivenNameKey,
            CNContactMiddleNameKey,
            CNContactFamilyNameKey,
            CNContactNameSuffixKey,
            CNContactNicknameKey,
            CNContactOrganizationNameKey,
            CNContactJobTitleKey,
            CNContactDepartmentNameKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactURLAddressesKey,
            CNContactPostalAddressesKey,
            CNContactSocialProfilesKey,
            CNContactNoteKey,
            CNContactBirthdayKey,
            CNContactImageDataKey,
            CNContactThumbnailImageDataKey
        ] as [CNKeyDescriptor]

        do {
            return try store.unifiedContact(withIdentifier: identifier, keysToFetch: keysToFetch)
        } catch {
            throw ContactsError.contactNotFound
        }
    }

    /// Fetch all contacts
    func fetchAllContacts() async throws -> [CNContact] {
        try await ensureAuthorized()

        let keysToFetch = [
            CNContactIdentifierKey,
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactOrganizationNameKey,
            CNContactThumbnailImageDataKey
        ] as [CNKeyDescriptor]

        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        var contacts: [CNContact] = []

        try store.enumerateContacts(with: fetchRequest) { contact, stop in
            contacts.append(contact)
        }

        return contacts
    }

    // MARK: - Contact Deletion

    /// Delete a contact by identifier
    func deleteContact(identifier: String) async throws {
        try await ensureAuthorized()

        guard let contact = try? store.unifiedContact(
            withIdentifier: identifier,
            keysToFetch: [CNContactIdentifierKey as CNKeyDescriptor]
        ) else {
            throw ContactsError.contactNotFound
        }

        guard let mutableContact = contact.mutableCopy() as? CNMutableContact else {
            AppLogger.contacts.error("Failed to create mutable copy for deletion")
            throw ContactsError.deleteFailed(underlying: NSError(
                domain: "com.deets.contacts",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to create mutable contact copy"]
            ))
        }

        let saveRequest = CNSaveRequest()
        saveRequest.delete(mutableContact)

        do {
            try store.execute(saveRequest)
        } catch {
            throw ContactsError.deleteFailed(underlying: error)
        }
    }

    // MARK: - Utility Methods

    /// Get formatted display name for a contact
    func displayName(for contact: CNContact) -> String {
        CNContactFormatter.string(from: contact, style: .fullName) ?? "Unknown"
    }

    /// Check if contacts feature is available
    static var isAvailable: Bool {
        true // Contacts framework is always available on iOS
    }

    /// Get permission status as user-friendly string
    var permissionStatusDescription: String {
        switch authorizationStatus {
        case .authorized:
            return "Authorized"
        case .denied:
            return "Denied - Please enable in Settings"
        case .restricted:
            return "Restricted by device policy"
        case .notDetermined:
            return "Not yet requested"
        @unknown default:
            return "Unknown status"
        }
    }
}

// MARK: - Error Types

enum ContactsError: LocalizedError, Identifiable {
    case accessDenied
    case insufficientData
    case duplicateFound(contacts: [CNContact])
    case contactNotFound
    case saveFailed(underlying: Error)
    case deleteFailed(underlying: Error)
    case batchSaveFailed(errors: [ContactsError])

    var id: String {
        switch self {
        case .accessDenied:
            return "access_denied"
        case .insufficientData:
            return "insufficient_data"
        case .duplicateFound:
            return "duplicate_found"
        case .contactNotFound:
            return "contact_not_found"
        case .saveFailed:
            return "save_failed"
        case .deleteFailed:
            return "delete_failed"
        case .batchSaveFailed:
            return "batch_save_failed"
        }
    }

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Access to Contacts was denied. Please enable in Settings > Privacy > Contacts."
        case .insufficientData:
            return "Not enough data to create a contact. Please ensure at least a name and phone or email is provided."
        case .duplicateFound(let contacts):
            return "Found \(contacts.count) potential duplicate contact(s)."
        case .contactNotFound:
            return "The requested contact could not be found."
        case .saveFailed(let error):
            return "Failed to save contact: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete contact: \(error.localizedDescription)"
        case .batchSaveFailed(let errors):
            return "Failed to save \(errors.count) contact(s)."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .accessDenied:
            return "Go to Settings > Privacy > Contacts and enable access for Deets."
        case .insufficientData:
            return "Edit the contact data to include at minimum a name and either a phone number or email address."
        case .duplicateFound:
            return "Review the potential duplicates and choose to merge, update, or create a new contact."
        case .contactNotFound:
            return "The contact may have been deleted. Try refreshing your contacts list."
        case .saveFailed, .deleteFailed, .batchSaveFailed:
            return "Please try again. If the problem persists, restart the app."
        }
    }
}

// MARK: - CNContact Extensions

extension CNContact {
    /// Convert CNContact back to ParsedContact (for editing)
    func toParsedContact() -> ParsedContact {
        var parsed = ParsedContact(rawText: "")

        // Name
        parsed.namePrefix = namePrefix
        parsed.givenName = givenName
        parsed.middleName = middleName
        parsed.familyName = familyName
        parsed.nameSuffix = nameSuffix
        parsed.nickname = nickname

        // Organization
        parsed.organizationName = organizationName
        parsed.jobTitle = jobTitle
        parsed.department = departmentName

        // Phones
        parsed.phoneNumbers = phoneNumbers.map { labeledValue in
            ParsedPhoneNumber(
                number: labeledValue.value.stringValue,
                label: labeledValue.label ?? CNLabelPhoneNumberMain,
                confidence: 1.0
            )
        }

        // Emails
        parsed.emailAddresses = emailAddresses.map { labeledValue in
            ParsedEmail(
                address: labeledValue.value as String,
                label: labeledValue.label ?? CNLabelWork,
                confidence: 1.0
            )
        }

        // URLs
        parsed.urls = urlAddresses.map { labeledValue in
            ParsedURL(
                url: labeledValue.value as String,
                label: labeledValue.label ?? CNLabelURLAddressHomePage,
                confidence: 1.0
            )
        }

        // Addresses
        parsed.postalAddresses = postalAddresses.map { labeledValue in
            let address = labeledValue.value
            return ParsedAddress(
                street: address.street,
                city: address.city,
                state: address.state,
                postalCode: address.postalCode,
                country: address.country,
                label: labeledValue.label ?? CNLabelWork,
                confidence: 1.0
            )
        }

        // Birthday
        parsed.birthday = birthday

        // Note
        parsed.note = note

        return parsed
    }

    /// Check if contact matches parsed contact (for duplicate detection)
    func matches(_ parsedContact: ParsedContact, strictness: DuplicateStrictness = .medium) -> Bool {
        switch strictness {
        case .strict:
            return matchesStrict(parsedContact)
        case .medium:
            return matchesMedium(parsedContact)
        case .loose:
            return matchesLoose(parsedContact)
        }
    }

    private func matchesStrict(_ parsed: ParsedContact) -> Bool {
        // Name and at least one contact method must match
        let nameMatches = givenName == parsed.givenName && familyName == parsed.familyName

        let phoneMatches = phoneNumbers.contains { phone in
            parsed.phoneNumbers.contains { parsedPhone in
                phone.value.stringValue.filter { $0.isNumber } ==
                parsedPhone.number.filter { $0.isNumber }
            }
        }

        let emailMatches = emailAddresses.contains { email in
            parsed.emailAddresses.contains { parsedEmail in
                (email.value as String).lowercased() == parsedEmail.address.lowercased()
            }
        }

        return nameMatches && (phoneMatches || emailMatches)
    }

    private func matchesMedium(_ parsed: ParsedContact) -> Bool {
        // Name OR contact method match
        let nameMatches = givenName == parsed.givenName && familyName == parsed.familyName

        let phoneMatches = phoneNumbers.contains { phone in
            parsed.phoneNumbers.contains { parsedPhone in
                phone.value.stringValue.filter { $0.isNumber } ==
                parsedPhone.number.filter { $0.isNumber }
            }
        }

        let emailMatches = emailAddresses.contains { email in
            parsed.emailAddresses.contains { parsedEmail in
                (email.value as String).lowercased() == parsedEmail.address.lowercased()
            }
        }

        return nameMatches || phoneMatches || emailMatches
    }

    private func matchesLoose(_ parsed: ParsedContact) -> Bool {
        // Partial name or contact method match
        let firstNameMatches = givenName == parsed.givenName
        let lastNameMatches = familyName == parsed.familyName

        let phoneMatches = phoneNumbers.contains { phone in
            parsed.phoneNumbers.contains { parsedPhone in
                phone.value.stringValue.filter { $0.isNumber } ==
                parsedPhone.number.filter { $0.isNumber }
            }
        }

        let emailMatches = emailAddresses.contains { email in
            parsed.emailAddresses.contains { parsedEmail in
                (email.value as String).lowercased() == parsedEmail.address.lowercased()
            }
        }

        return firstNameMatches || lastNameMatches || phoneMatches || emailMatches
    }

    enum DuplicateStrictness {
        case strict   // Name + contact method must match
        case medium   // Name OR contact method
        case loose    // Partial name OR contact method
    }
}
