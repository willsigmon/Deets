package com.sharedeets.domain.model

import java.util.Date
import java.util.UUID

/**
 * Represents a contact parsed from OCR text with validation metadata
 * Mirrors iOS ParsedContact model
 */
data class ParsedContact(
    // Name Components
    val namePrefix: String? = null,
    val givenName: String? = null,
    val middleName: String? = null,
    val familyName: String? = null,
    val nameSuffix: String? = null,
    val nickname: String? = null,

    // Organization
    val organizationName: String? = null,
    val jobTitle: String? = null,
    val department: String? = null,

    // Contact Methods
    val phoneNumbers: List<ParsedPhoneNumber> = emptyList(),
    val emailAddresses: List<ParsedEmail> = emptyList(),
    val urls: List<ParsedURL> = emptyList(),

    // Addresses
    val postalAddresses: List<ParsedAddress> = emptyList(),

    // Social
    val socialProfiles: List<ParsedSocialProfile> = emptyList(),

    // Additional
    val note: String? = null,
    val birthday: String? = null,

    // Metadata
    val confidenceScores: ConfidenceScores = ConfidenceScores(),
    val validationFlags: ValidationFlags = ValidationFlags(),
    val rawText: String,
    val parseDate: Date = Date()
) {
    /**
     * Confidence tracking for parsed fields
     */
    data class ConfidenceScores(
        val name: Double = 0.0,
        val phone: Double = 0.0,
        val email: Double = 0.0,
        val address: Double = 0.0,
        val organization: Double = 0.0
    ) {
        val overall: Double
            get() {
                val scores = listOf(name, phone, email, address, organization)
                val validScores = scores.filter { it > 0 }
                return if (validScores.isEmpty()) 0.0 else validScores.average()
            }
    }

    /**
     * Validation flags for parsed data
     */
    data class ValidationFlags(
        val hasValidName: Boolean = false,
        val hasValidPhone: Boolean = false,
        val hasValidEmail: Boolean = false,
        val hasValidAddress: Boolean = false,
        val hasPotentialDuplicates: Boolean = false
    ) {
        val hasMinimumData: Boolean
            get() = hasValidName && (hasValidPhone || hasValidEmail)
    }

    /**
     * Quick validation check
     */
    val isValidForSaving: Boolean
        get() = validationFlags.hasMinimumData &&
                (validationFlags.hasValidName || validationFlags.hasValidPhone || validationFlags.hasValidEmail)

    /**
     * Human-readable summary
     */
    val summary: String
        get() {
            val parts = mutableListOf<String>()

            givenName?.let { parts.add(it) }
            familyName?.let { parts.add(it) }
            organizationName?.let { parts.add("($it)") }

            val contactMethods = listOfNotNull(
                if (phoneNumbers.isNotEmpty()) "${phoneNumbers.size} phone" else null,
                if (emailAddresses.isNotEmpty()) "${emailAddresses.size} email" else null,
                if (urls.isNotEmpty()) "${urls.size} URL" else null
            ).joinToString(", ")

            if (contactMethods.isNotEmpty()) {
                parts.add("- $contactMethods")
            }

            return parts.joinToString(" ")
        }
}

/**
 * Parsed phone number with metadata
 */
data class ParsedPhoneNumber(
    val id: String = UUID.randomUUID().toString(),
    val number: String,
    val label: String = "Work",
    val formattedNumber: String? = null,
    val confidence: Double = 1.0,
    val isValid: Boolean = false
)

/**
 * Parsed email with metadata
 */
data class ParsedEmail(
    val id: String = UUID.randomUUID().toString(),
    val address: String,
    val label: String = "Work",
    val confidence: Double = 1.0,
    val isValid: Boolean = false
)

/**
 * Parsed URL with metadata
 */
data class ParsedURL(
    val id: String = UUID.randomUUID().toString(),
    val url: String,
    val label: String = "Website",
    val type: URLType = URLType.WEBSITE,
    val confidence: Double = 1.0,
    val isValid: Boolean = false
) {
    enum class URLType {
        WEBSITE, LINKEDIN, TWITTER, FACEBOOK, INSTAGRAM, OTHER
    }
}

/**
 * Parsed address with metadata
 */
data class ParsedAddress(
    val id: String = UUID.randomUUID().toString(),
    val street: String? = null,
    val city: String? = null,
    val state: String? = null,
    val postalCode: String? = null,
    val country: String? = null,
    val label: String = "Work",
    val confidence: Double = 1.0,
    val isValid: Boolean = false
) {
    val hasMinimumData: Boolean
        get() = (street != null || city != null) && (state != null || postalCode != null)
}

/**
 * Parsed social profile with metadata
 */
data class ParsedSocialProfile(
    val id: String = UUID.randomUUID().toString(),
    val username: String,
    val service: String,
    val url: String? = null,
    val confidence: Double = 1.0
)
