package com.sharedeets.domain.model

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.Date
import java.util.UUID

/**
 * Business Card entity for Room database
 * Mirrors iOS SwiftData BusinessCard model
 */
@Entity(tableName = "business_cards")
data class BusinessCard(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),

    // Contact Information
    val fullName: String,
    val jobTitle: String? = null,
    val company: String? = null,
    val email: String? = null,
    val phoneNumber: String? = null,
    val website: String? = null,
    val address: String? = null,
    val notes: String? = null,

    // Metadata
    val rawText: String,
    val dateScanned: Date = Date(),
    val dateModified: Date = Date(),
    val savedToContacts: Boolean = false,

    // Organization
    val tags: List<String> = emptyList(),
    val isFavorite: Boolean = false,

    // Cloud Sync Metadata (for Google Drive sync)
    val cloudModificationDate: Date? = null,
    val isLocalOnly: Boolean = true
) {
    /**
     * Display name for list views
     */
    val displayName: String
        get() = fullName.ifEmpty { "Unknown Contact" }

    /**
     * Subtitle for list views (company or job title)
     */
    val displaySubtitle: String?
        get() = company?.takeIf { it.isNotEmpty() } ?: jobTitle

    /**
     * Whether the card has valid contact information
     */
    val hasContactInfo: Boolean
        get() = email != null || phoneNumber != null

    /**
     * Search text for filtering
     */
    val searchableText: String
        get() = listOfNotNull(
            fullName,
            jobTitle,
            company,
            email,
            phoneNumber,
            notes
        ).joinToString(" ").lowercase()

    companion object {
        /**
         * Sample data for previews and testing
         */
        val sampleData = listOf(
            BusinessCard(
                fullName = "Sarah Chen",
                jobTitle = "Senior Product Designer",
                company = "Acme Design Co",
                email = "sarah.chen@acme.design",
                phoneNumber = "+1 (555) 123-4567",
                website = "https://acme.design",
                rawText = "Sarah Chen\nSenior Product Designer\nAcme Design Co\nsarah.chen@acme.design\n+1 (555) 123-4567",
                tags = listOf("Design", "Client"),
                isFavorite = true
            ),
            BusinessCard(
                fullName = "Marcus Rodriguez",
                jobTitle = "CTO",
                company = "TechStart Inc",
                email = "m.rodriguez@techstart.io",
                phoneNumber = "+1 (555) 987-6543",
                rawText = "Marcus Rodriguez\nCTO\nTechStart Inc\nm.rodriguez@techstart.io",
                tags = listOf("Tech", "Networking")
            ),
            BusinessCard(
                fullName = "Emily Watson",
                jobTitle = "Marketing Director",
                company = "Creative Solutions",
                email = "e.watson@creativesolutions.com",
                phoneNumber = "+1 (555) 246-8135",
                website = "https://creativesolutions.com",
                address = "123 Main St, San Francisco, CA 94102",
                rawText = "Emily Watson\nMarketing Director\nCreative Solutions",
                savedToContacts = true,
                tags = listOf("Marketing")
            )
        )
    }
}
