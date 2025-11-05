//
//  ExportOptionsView.swift
//  Deets
//
//  Export options UI with format selection and field customization
//

import SwiftUI

struct ExportOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ExportViewModel

    var body: some View {
        NavigationStack {
            Form {
                // Format Selection
                Section {
                    ForEach(ExportFormat.allCases) { format in
                        FormatSelectionRow(
                            format: format,
                            isSelected: viewModel.selectedFormat == format
                        ) {
                            viewModel.selectedFormat = format
                            HapticManager.shared.buttonTap()
                        }
                    }
                } header: {
                    Text("Export Format")
                } footer: {
                    Text(viewModel.selectedFormat.description)
                }

                // CSV Field Selection (only show for CSV format)
                if viewModel.selectedFormat == .csv {
                    Section {
                        // Select/Deselect All
                        Button {
                            viewModel.toggleAllFields()
                            HapticManager.shared.buttonTap()
                        } label: {
                            HStack {
                                Text(viewModel.selectedFields.count == CSVExporter.allFields.count ? "Deselect All" : "Select All")
                                Spacer()
                                Text("\(viewModel.selectedFields.count)/\(CSVExporter.allFields.count)")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        // Individual field toggles
                        ForEach(CSVExporter.ExportField.allCases) { field in
                            FieldSelectionRow(
                                field: field,
                                isSelected: viewModel.isFieldSelected(field),
                                isRequired: field == .fullName
                            ) {
                                viewModel.toggleField(field)
                                HapticManager.shared.buttonTap()
                            }
                        }
                    } header: {
                        Text("CSV Fields")
                    } footer: {
                        Text("Full Name is required and cannot be deselected")
                    }
                }

                // Preview Section
                Section {
                    Button {
                        viewModel.generatePreview()
                        viewModel.showPreview = true
                        HapticManager.shared.buttonTap()
                    } label: {
                        Label("Preview Export", systemImage: "eye")
                    }
                    .disabled(!viewModel.canExport)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("Export Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Export") {
                        Task {
                            await viewModel.performExport()
                        }
                    }
                    .disabled(!viewModel.canExport)
                }
            }
            .sheet(isPresented: $viewModel.showPreview) {
                ExportPreviewView(
                    previewText: viewModel.previewText,
                    format: viewModel.selectedFormat
                )
            }
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let url = viewModel.exportedFileURL {
                    ExportShareSheet(fileURL: url) {
                        dismiss()
                    }
                }
            }
            .alert("Export Error", isPresented: .constant(viewModel.exportService.lastExportError != nil)) {
                Button("OK") {
                    viewModel.exportService.lastExportError = nil
                }
            } message: {
                if let error = viewModel.exportService.lastExportError {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Format Selection Row

struct FormatSelectionRow: View {
    let format: ExportFormat
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: format.icon)
                    .font(.title3)
                    .foregroundStyle(Color.teal)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(format.rawValue)
                        .font(.body)
                        .foregroundStyle(.primary)

                    Text(fileExtension)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.teal)
                }
            }
        }
        .accessibilityLabel("\(format.rawValue), \(isSelected ? "selected" : "not selected")")
    }

    private var fileExtension: String {
        ".\(format.fileExtension) file"
    }
}

// MARK: - Field Selection Row

struct FieldSelectionRow: View {
    let field: CSVExporter.ExportField
    let isSelected: Bool
    let isRequired: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isSelected ? Color.teal : .secondary)

                Text(field.rawValue)

                if isRequired {
                    Text("(Required)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
        .disabled(isRequired && isSelected)
        .accessibilityLabel("\(field.rawValue), \(isRequired ? "required, " : "")\(isSelected ? "selected" : "not selected")")
    }
}

// MARK: - Export Preview View

struct ExportPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let previewText: String
    let format: ExportFormat

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(previewText)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Export Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Quick Export Button

/// Quick export button for single card (no options)
struct QuickExportButton: View {
    let card: BusinessCard
    @State private var viewModel = ExportViewModel()

    var body: some View {
        Button {
            Task {
                viewModel.configureSingleCard(card)
                await viewModel.performExport()
            }
        } label: {
            Label("Export", systemImage: "square.and.arrow.up")
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let url = viewModel.exportedFileURL {
                ExportShareSheet(fileURL: url, onDismiss: nil)
            }
        }
        .alert("Export Error", isPresented: .constant(viewModel.exportService.lastExportError != nil)) {
            Button("OK") {
                viewModel.exportService.lastExportError = nil
            }
        } message: {
            if let error = viewModel.exportService.lastExportError {
                Text(error.localizedDescription)
            }
        }
    }
}

// MARK: - Previews

#Preview("Export Options - vCard") {
    ExportOptionsView(viewModel: {
        let vm = ExportViewModel()
        vm.configureSingleCard(BusinessCard.sampleData[0])
        vm.selectedFormat = .vcard
        return vm
    }())
}

#Preview("Export Options - CSV") {
    ExportOptionsView(viewModel: {
        let vm = ExportViewModel()
        vm.configureMultipleCards(BusinessCard.sampleData)
        vm.selectedFormat = .csv
        return vm
    }())
}
