package com.deets.services

import com.deets.domain.model.*
import java.util.regex.Pattern
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Service for parsing contact information from OCR text
 * Mirrors iOS ContactParser logic
 */
@Singleton
class ContactParserService @Inject constructor() {

    companion object {
        // Regex patterns for contact information
        private val EMAIL_PATTERN = Pattern.compile(
            "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}"
        )

        private val PHONE_PATTERN = Pattern.compile(
            "(?:\\+?1[-.\\s]?)?(?:\\(?([0-9]{3})\\)?[-.\\s]?)?([0-9]{3})[-.\\s]?([0-9]{4})"
        )

        private val URL_PATTERN = Pattern.compile(
            "(?:https?://)?(?:www\\.)?[a-zA-Z0-9-]+\\.[a-zA-Z]{2,}(?:/[^\\s]*)?"
        )

        private val SOCIAL_PATTERNS = mapOf(
            "LinkedIn" to Pattern.compile("(?:linkedin\\.com/in/|@?linkedin:)\\s*([\\w-]+)", Pattern.CASE_INSENSITIVE),
            "Twitter" to Pattern.compile("(?:twitter\\.com/|@)([\\w]+)", Pattern.CASE_INSENSITIVE),
            "Facebook" to Pattern.compile("(?:facebook\\.com/)([\\w.]+)", Pattern.CASE_INSENSITIVE),
            "Instagram" to Pattern.compile("(?:instagram\\.com/|@ig:)\\s*([\\w.]+)", Pattern.CASE_INSENSITIVE)
        )

        // Common job titles for organization parsing
        private val JOB_TITLES = setOf(
            "CEO", "CTO", "CFO", "COO", "President", "VP", "Director", "Manager",
            "Engineer", "Developer", "Designer", "Analyst", "Consultant", "Specialist",
            "Lead", "Senior", "Junior", "Associate", "Principal", "Head"
        )
    }

    /**
     * Parse OCR text into structured contact information
     */
    fun parseContact(text: String): ParsedContact {
        val lines = text.lines().filter { it.isNotBlank() }

        val emails = extractEmails(text)
        val phones = extractPhoneNumbers(text)
        val urls = extractURLs(text)
        val socials = extractSocialProfiles(text)

        // Extract name (typically first non-empty line)
        val (givenName, familyName) = extractName(lines.firstOrNull() ?: "")

        // Extract organization and job title
        val (organization, jobTitle) = extractOrganizationInfo(lines)

        // Calculate confidence scores
        val confidenceScores = calculateConfidenceScores(
            hasName = givenName != null || familyName != null,
            emailCount = emails.size,
            phoneCount = phones.size
        )

        // Validation flags
        val validationFlags = ParsedContact.ValidationFlags(
            hasValidName = givenName != null || familyName != null,
            hasValidPhone = phones.any { it.isValid },
            hasValidEmail = emails.any { it.isValid },
            hasValidAddress = false
        )

        return ParsedContact(
            givenName = givenName,
            familyName = familyName,
            organizationName = organization,
            jobTitle = jobTitle,
            phoneNumbers = phones,
            emailAddresses = emails,
            urls = urls,
            socialProfiles = socials,
            confidenceScores = confidenceScores,
            validationFlags = validationFlags,
            rawText = text
        )
    }

    private fun extractEmails(text: String): List<ParsedEmail> {
        val matcher = EMAIL_PATTERN.matcher(text)
        val emails = mutableListOf<ParsedEmail>()

        while (matcher.find()) {
            val email = matcher.group()
            emails.add(
                ParsedEmail(
                    address = email.lowercase(),
                    isValid = isValidEmail(email),
                    confidence = 0.9
                )
            )
        }

        return emails
    }

    private fun extractPhoneNumbers(text: String): List<ParsedPhoneNumber> {
        val matcher = PHONE_PATTERN.matcher(text)
        val phones = mutableListOf<ParsedPhoneNumber>()

        while (matcher.find()) {
            val phone = matcher.group()
            phones.add(
                ParsedPhoneNumber(
                    number = phone,
                    formattedNumber = formatPhoneNumber(phone),
                    isValid = isValidPhoneNumber(phone),
                    confidence = 0.85
                )
            )
        }

        return phones
    }

    private fun extractURLs(text: String): List<ParsedURL> {
        val matcher = URL_PATTERN.matcher(text)
        val urls = mutableListOf<ParsedURL>()

        while (matcher.find()) {
            val url = matcher.group()
            if (!url.contains("@")) { // Exclude emails
                urls.add(
                    ParsedURL(
                        url = normalizeURL(url),
                        isValid = true,
                        confidence = 0.8
                    )
                )
            }
        }

        return urls
    }

    private fun extractSocialProfiles(text: String): List<ParsedSocialProfile> {
        val profiles = mutableListOf<ParsedSocialProfile>()

        SOCIAL_PATTERNS.forEach { (service, pattern) ->
            val matcher = pattern.matcher(text)
            while (matcher.find()) {
                val username = matcher.group(1)
                if (username != null) {
                    profiles.add(
                        ParsedSocialProfile(
                            username = username,
                            service = service,
                            confidence = 0.75
                        )
                    )
                }
            }
        }

        return profiles
    }

    private fun extractName(line: String): Pair<String?, String?> {
        val parts = line.trim().split("\\s+".toRegex())
        return when {
            parts.isEmpty() -> null to null
            parts.size == 1 -> parts[0] to null
            else -> parts.first() to parts.last()
        }
    }

    private fun extractOrganizationInfo(lines: List<String>): Pair<String?, String?> {
        var organization: String? = null
        var jobTitle: String? = null

        for (line in lines.drop(1)) { // Skip first line (name)
            val trimmedLine = line.trim()

            // Check if line contains job title keywords
            if (jobTitle == null && JOB_TITLES.any { trimmedLine.contains(it, ignoreCase = true) }) {
                jobTitle = trimmedLine
            } else if (organization == null && trimmedLine.isNotEmpty()) {
                // Assume next line after job title (or second line) is organization
                organization = trimmedLine
            }

            if (organization != null && jobTitle != null) break
        }

        return organization to jobTitle
    }

    private fun calculateConfidenceScores(
        hasName: Boolean,
        emailCount: Int,
        phoneCount: Int
    ): ParsedContact.ConfidenceScores {
        return ParsedContact.ConfidenceScores(
            name = if (hasName) 0.9 else 0.0,
            phone = if (phoneCount > 0) 0.85 else 0.0,
            email = if (emailCount > 0) 0.9 else 0.0,
            address = 0.0,
            organization = 0.7
        )
    }

    // Validation helpers
    private fun isValidEmail(email: String): Boolean {
        return email.contains("@") && email.contains(".")
    }

    private fun isValidPhoneNumber(phone: String): Boolean {
        val digits = phone.filter { it.isDigit() }
        return digits.length in 10..15
    }

    private fun formatPhoneNumber(phone: String): String {
        val digits = phone.filter { it.isDigit() }
        return when {
            digits.length == 10 -> "(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}"
            digits.length == 11 && digits.startsWith("1") ->
                "+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}"
            else -> phone
        }
    }

    private fun normalizeURL(url: String): String {
        return if (!url.startsWith("http")) "https://$url" else url
    }
}
