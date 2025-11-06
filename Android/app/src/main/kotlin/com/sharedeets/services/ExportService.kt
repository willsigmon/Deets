package com.sharedeets.services

import android.content.Context
import com.sharedeets.domain.model.BusinessCard
import com.opencsv.CSVWriter
import dagger.hilt.android.qualifiers.ApplicationContext
import ezvcard.Ezvcard
import ezvcard.VCard
import ezvcard.parameter.EmailType
import ezvcard.parameter.TelephoneType
import ezvcard.property.*
import java.io.File
import java.io.FileWriter
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Service for exporting business cards to various formats
 * Mirrors iOS ExportService
 */
@Singleton
class ExportService @Inject constructor(
    @ApplicationContext private val context: Context
) {

    /**
     * Export single card to vCard format
     */
    fun exportToVCard(card: BusinessCard): Result<File> {
        return try {
            val vcard = createVCard(card)
            val vcardString = Ezvcard.write(vcard).go()

            val file = File(context.cacheDir, "${card.fullName.replace(" ", "_")}.vcf")
            file.writeText(vcardString)

            Result.success(file)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Export multiple cards to vCard format
     */
    fun exportMultipleToVCard(cards: List<BusinessCard>): Result<File> {
        return try {
            val vcards = cards.map { createVCard(it) }
            val vcardString = Ezvcard.write(vcards).go()

            val file = File(context.cacheDir, "deets_export_${System.currentTimeMillis()}.vcf")
            file.writeText(vcardString)

            Result.success(file)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Export cards to CSV format
     */
    fun exportToCSV(cards: List<BusinessCard>): Result<File> {
        return try {
            val file = File(context.cacheDir, "deets_export_${System.currentTimeMillis()}.csv")
            val writer = CSVWriter(FileWriter(file))

            // Write header
            writer.writeNext(
                arrayOf(
                    "Full Name",
                    "Job Title",
                    "Company",
                    "Email",
                    "Phone",
                    "Website",
                    "Address",
                    "Notes",
                    "Tags",
                    "Date Scanned",
                    "Favorite"
                )
            )

            // Write data
            cards.forEach { card ->
                writer.writeNext(
                    arrayOf(
                        card.fullName,
                        card.jobTitle ?: "",
                        card.company ?: "",
                        card.email ?: "",
                        card.phoneNumber ?: "",
                        card.website ?: "",
                        card.address ?: "",
                        card.notes ?: "",
                        card.tags.joinToString(";"),
                        card.dateScanned.toString(),
                        if (card.isFavorite) "Yes" else "No"
                    )
                )
            }

            writer.close()
            Result.success(file)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Create VCard from BusinessCard
     */
    private fun createVCard(card: BusinessCard): VCard {
        val vcard = VCard()

        // Name
        val nameParts = card.fullName.split(" ")
        val structuredName = StructuredName().apply {
            given = nameParts.firstOrNull()
            family = nameParts.lastOrNull()
        }
        vcard.structuredName = structuredName
        vcard.formattedName = FormattedName(card.fullName)

        // Organization
        if (card.company != null) {
            vcard.organization = Organization().apply {
                values.add(card.company)
            }
        }

        // Title
        if (card.jobTitle != null) {
            vcard.addTitle(card.jobTitle)
        }

        // Email
        if (card.email != null) {
            vcard.addEmail(Email(card.email).apply {
                types.add(EmailType.WORK)
            })
        }

        // Phone
        if (card.phoneNumber != null) {
            vcard.addTelephoneNumber(Telephone(card.phoneNumber).apply {
                types.add(TelephoneType.WORK)
            })
        }

        // Website
        if (card.website != null) {
            vcard.addUrl(card.website)
        }

        // Address
        if (card.address != null) {
            vcard.addAddress(Address().apply {
                label = card.address
            })
        }

        // Notes
        if (card.notes != null) {
            vcard.addNote(card.notes)
        }

        // Categories (tags)
        if (card.tags.isNotEmpty()) {
            vcard.categories = Categories().apply {
                values.addAll(card.tags)
            }
        }

        // Revision
        vcard.revision = Revision.now()

        return vcard
    }
}
