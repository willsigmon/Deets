//
//  ExportService.swift
//  Deets
//
//  Unified export service with share sheet integration
//  Handles both single and batch exports in multiple formats
//

import Foundation
import UIKit
import SwiftUI

/// Export format options
enum ExportFormat: String, CaseIterable, Identifiable {
    case vcard = "vCard (.vcf)"
    case csv = "CSV (.csv)"

    var id: String { rawValue }

    var fileExtension: String {
        switch self {
        case .vcard: return "vcf"
        case .csv: return "csv"
        }
    }

    var mimeType: String {
        switch self {
        case .vcard: return "text/vcard"
        case .csv: return "text/csv"
        }
    }
}

/// Export scope - what to export
enum ExportScope {
    case single(BusinessCard)
    case multiple([BusinessCard])
    case all([BusinessCard])
}

/// Result of export operation
enum ExportResult {
    case success(URL)
    case failure(ExportError)
}

/// Export errors
enum ExportError: LocalizedError, Equatable {
    case noCards
    case invalidFormat
    case fileCreationFailed
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .noCards:
            return "No cards selected for export"
        case .invalidFormat:
            return "Invalid export format"
        case .fileCreationFailed:
            return "Failed to create export file"
        case .encodingFailed:
            return "Failed to encode export data"
        }
    }
}

/// Main export service
@MainActor
class ExportService: ObservableObject {

    // MARK: - Properties

    @Published var isExporting = false
    @Published var exportProgress: Double = 0.0
    @Published var lastExportError: ExportError?

    // MARK: - Export Methods

    /// Export a single card
    func exportCard(
        _ card: BusinessCard,
        format: ExportFormat,
        fields: [CSVExporter.ExportField] = CSVExporter.defaultFields
    ) async -> ExportResult {
        isExporting = true
        exportProgress = 0.0

        defer {
            isExporting = false
            exportProgress = 1.0
        }

        do {
            let content = generateContent(
                scope: .single(card),
                format: format,
                fields: fields
            )

            guard !content.isEmpty else {
                throw ExportError.encodingFailed
            }

            let filename = generateFilename(
                scope: .single(card),
                format: format
            )

            let url = try await writeToTemporaryFile(
                content: content,
                filename: filename,
                format: format
            )

            exportProgress = 1.0
            return .success(url)

        } catch let error as ExportError {
            lastExportError = error
            return .failure(error)
        } catch {
            lastExportError = .fileCreationFailed
            return .failure(.fileCreationFailed)
        }
    }

    /// Export multiple cards
    func exportCards(
        _ cards: [BusinessCard],
        format: ExportFormat,
        fields: [CSVExporter.ExportField] = CSVExporter.defaultFields
    ) async -> ExportResult {
        guard !cards.isEmpty else {
            lastExportError = .noCards
            return .failure(.noCards)
        }

        isExporting = true
        exportProgress = 0.0

        defer {
            isExporting = false
            exportProgress = 1.0
        }

        do {
            let content = generateContent(
                scope: .multiple(cards),
                format: format,
                fields: fields
            )

            guard !content.isEmpty else {
                throw ExportError.encodingFailed
            }

            let filename = generateFilename(
                scope: .multiple(cards),
                format: format
            )

            let url = try await writeToTemporaryFile(
                content: content,
                filename: filename,
                format: format
            )

            exportProgress = 1.0
            return .success(url)

        } catch let error as ExportError {
            lastExportError = error
            return .failure(error)
        } catch {
            lastExportError = .fileCreationFailed
            return .failure(.fileCreationFailed)
        }
    }

    // MARK: - Content Generation

    private func generateContent(
        scope: ExportScope,
        format: ExportFormat,
        fields: [CSVExporter.ExportField]
    ) -> String {
        switch scope {
        case .single(let card):
            return generateSingleContent(card: card, format: format, fields: fields)

        case .multiple(let cards), .all(let cards):
            return generateMultipleContent(cards: cards, format: format, fields: fields)
        }
    }

    private func generateSingleContent(
        card: BusinessCard,
        format: ExportFormat,
        fields: [CSVExporter.ExportField]
    ) -> String {
        switch format {
        case .vcard:
            return VCardExporter.exportCard(card)
        case .csv:
            return CSVExporter.exportCard(card, fields: fields)
        }
    }

    private func generateMultipleContent(
        cards: [BusinessCard],
        format: ExportFormat,
        fields: [CSVExporter.ExportField]
    ) -> String {
        switch format {
        case .vcard:
            return VCardExporter.exportMultipleCards(cards)
        case .csv:
            return CSVExporter.exportCards(cards, fields: fields)
        }
    }

    // MARK: - Filename Generation

    private func generateFilename(
        scope: ExportScope,
        format: ExportFormat
    ) -> String {
        switch scope {
        case .single(let card):
            return generateSingleFilename(card: card, format: format)

        case .multiple(let cards), .all(let cards):
            return generateMultipleFilename(count: cards.count, format: format)
        }
    }

    private func generateSingleFilename(
        card: BusinessCard,
        format: ExportFormat
    ) -> String {
        switch format {
        case .vcard:
            return VCardExporter.generateFilename(for: card)
        case .csv:
            return CSVExporter.generateFilename(for: card)
        }
    }

    private func generateMultipleFilename(
        count: Int,
        format: ExportFormat
    ) -> String {
        switch format {
        case .vcard:
            return VCardExporter.generateFilename(count: count)
        case .csv:
            return CSVExporter.generateFilename(count: count)
        }
    }

    // MARK: - File Writing

    private func writeToTemporaryFile(
        content: String,
        filename: String,
        format: ExportFormat
    ) async throws -> URL {
        guard let data = content.data(using: .utf8) else {
            throw ExportError.encodingFailed
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            throw ExportError.fileCreationFailed
        }
    }

    // MARK: - Share Sheet Helpers

    /// Create share items for UIActivityViewController
    func createShareItems(fileURL: URL) -> [Any] {
        [fileURL]
    }

    /// Create share items with text fallback
    func createShareItemsWithFallback(fileURL: URL, text: String) -> [Any] {
        [fileURL, text]
    }

    // MARK: - Preview Generation

    /// Generate a preview of the export
    func generatePreview(
        cards: [BusinessCard],
        format: ExportFormat,
        fields: [CSVExporter.ExportField] = CSVExporter.defaultFields,
        maxRows: Int = 5
    ) -> String {
        switch format {
        case .vcard:
            let previewCards = Array(cards.prefix(maxRows))
            let vcard = VCardExporter.exportMultipleCards(previewCards)
            if cards.count > maxRows {
                return vcard + "\n... (\(cards.count - maxRows) more contacts)"
            }
            return vcard

        case .csv:
            return CSVExporter.generatePreview(cards, fields: fields, maxRows: maxRows)
        }
    }
}

// MARK: - SwiftUI Share Integration

/// SwiftUI wrapper for sharing exported files
struct ExportShareSheet: UIViewControllerRepresentable {
    let fileURL: URL
    let onDismiss: (() -> Void)?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )

        controller.completionWithItemsHandler = { _, _, _, _ in
            onDismiss?()
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Export Data for iOS 16+ ShareLink

@available(iOS 16.0, *)
extension BusinessCard {
    /// Create transferable representation for ShareLink
    func exportData(format: ExportFormat) -> Data? {
        let content: String

        switch format {
        case .vcard:
            content = VCardExporter.exportCard(self)
        case .csv:
            content = CSVExporter.exportCard(self)
        }

        return content.data(using: .utf8)
    }
}
