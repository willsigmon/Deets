//
//  BusinessCard.swift
//  Deets
//
//  SwiftData model for storing business card information
//

import Foundation
import SwiftData

@Model
final class BusinessCard {
    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Full name from card
    var fullName: String

    /// Job title
    var jobTitle: String?

    /// Company/Organization name
    /// Indexed for faster company-based queries and sorting
    @Attribute(.indexed) var company: String?

    /// Email address
    var email: String?

    /// Phone number
    var phoneNumber: String?

    /// Website URL
    var website: String?

    /// Physical address
    var address: String?

    /// Additional notes
    var notes: String?

    /// Original scanned text (for reference)
    var rawText: String

    /// Date card was scanned
    /// Indexed for faster date-based sorting and filtering
    @Attribute(.indexed) var dateScanned: Date

    /// Date last modified
    var dateModified: Date

    /// Whether card has been saved to Contacts
    var savedToContacts: Bool

    /// Tags for categorization
    var tags: [String]

    /// Favorite status
    var isFavorite: Bool

    // MARK: - CloudKit Sync Metadata

    /// CloudKit record modification date (managed by system)
    /// This helps track sync conflicts and last server update
    var cloudKitModificationDate: Date?

    /// Whether this record was created locally or synced from cloud
    var isLocalOnly: Bool = true

    // MARK: - Performance Cache

    /// Cached searchable text to avoid recomputation on every access
    /// Automatically invalidated when related properties change
    private var cachedSearchableText: String?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        fullName: String,
        jobTitle: String? = nil,
        company: String? = nil,
        email: String? = nil,
        phoneNumber: String? = nil,
        website: String? = nil,
        address: String? = nil,
        notes: String? = nil,
        rawText: String,
        dateScanned: Date = Date(),
        dateModified: Date = Date(),
        savedToContacts: Bool = false,
        tags: [String] = [],
        isFavorite: Bool = false,
        cloudKitModificationDate: Date? = nil,
        isLocalOnly: Bool = true
    ) {
        self.id = id
        self.fullName = fullName
        self.jobTitle = jobTitle
        self.company = company
        self.email = email
        self.phoneNumber = phoneNumber
        self.website = website
        self.address = address
        self.notes = notes
        self.rawText = rawText
        self.dateScanned = dateScanned
        self.dateModified = dateModified
        self.savedToContacts = savedToContacts
        self.tags = tags
        self.isFavorite = isFavorite
        self.cloudKitModificationDate = cloudKitModificationDate
        self.isLocalOnly = isLocalOnly
    }

    // MARK: - Computed Properties

    /// Display name for list views
    var displayName: String {
        fullName.isEmpty ? "Unknown Contact" : fullName
    }

    /// Subtitle for list views (company or job title)
    var displaySubtitle: String? {
        if let company = company, !company.isEmpty {
            return company
        }
        return jobTitle
    }

    /// Whether the card has valid contact information
    var hasContactInfo: Bool {
        email != nil || phoneNumber != nil
    }

    /// Search text for filtering with performance caching
    /// Cached to avoid recomputing on every render (significant speedup for large lists)
    var searchableText: String {
        // Return cached value if available
        if let cached = cachedSearchableText {
            return cached
        }

        // Compute and cache the searchable text
        let computed = [fullName, jobTitle, company, email, phoneNumber, notes]
            .compactMap { $0 }
            .joined(separator: " ")
            .lowercased()

        cachedSearchableText = computed
        return computed
    }

    /// Invalidate searchable text cache when any relevant property changes
    /// Call this after modifying fullName, jobTitle, company, email, phoneNumber, or notes
    func invalidateSearchCache() {
        cachedSearchableText = nil
    }
}

// MARK: - Sample Data

extension BusinessCard {
    /// Sample data for previews and testing
    static var sampleData: [BusinessCard] {
        [
            BusinessCard(
                fullName: "Sarah Chen",
                jobTitle: "Senior Product Designer",
                company: "Acme Design Co",
                email: "sarah.chen@acme.design",
                phoneNumber: "+1 (555) 123-4567",
                website: "https://acme.design",
                rawText: "Sarah Chen\\nSenior Product Designer\\nAcme Design Co\\nsarah.chen@acme.design\\n+1 (555) 123-4567",
                tags: ["Design", "Client"],
                isFavorite: true
            ),
            BusinessCard(
                fullName: "Marcus Rodriguez",
                jobTitle: "CTO",
                company: "TechStart Inc",
                email: "m.rodriguez@techstart.io",
                phoneNumber: "+1 (555) 987-6543",
                rawText: "Marcus Rodriguez\\nCTO\\nTechStart Inc\\nm.rodriguez@techstart.io",
                tags: ["Tech", "Networking"]
            ),
            BusinessCard(
                fullName: "Emily Watson",
                jobTitle: "Marketing Director",
                company: "Creative Solutions",
                email: "e.watson@creativesolutions.com",
                phoneNumber: "+1 (555) 246-8135",
                website: "https://creativesolutions.com",
                address: "123 Main St, San Francisco, CA 94102",
                rawText: "Emily Watson\\nMarketing Director\\nCreative Solutions",
                savedToContacts: true,
                tags: ["Marketing"]
            )
        ]
    }
}
