//
//  ContactPreviewView.swift
//  Deets
//
//  Editable contact preview after scanning
//

import SwiftUI
import SwiftData

struct ContactPreviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ContactPreviewViewModel
    let onDismiss: () -> Void

    init(scannedText: String, onDismiss: @escaping () -> Void) {
        _viewModel = State(initialValue: ContactPreviewViewModel(scannedText: scannedText))
        self.onDismiss = onDismiss
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .iconRegular()
                            .foregroundStyle(Color.teal)
                            .accessibilityHidden(true)

                        Text("Review Contact")
                            .font(.title2.weight(.bold))

                        Text("Verify and edit the extracted information")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 24)

                    // Form fields
                    VStack(spacing: 20) {
                        // Name (required)
                        ValidatedTextField(
                            title: "Full Name *",
                            placeholder: "John Doe",
                            text: $viewModel.fullName,
                            isValid: !viewModel.fullName.isEmpty,
                            textContentType: .name,
                            icon: "person.fill"
                        )

                        // Job Title
                        ValidatedTextField(
                            title: "Job Title",
                            placeholder: "Product Manager",
                            text: $viewModel.jobTitle,
                            textContentType: .jobTitle,
                            icon: "briefcase.fill"
                        )

                        // Company
                        ValidatedTextField(
                            title: "Company",
                            placeholder: "Acme Inc",
                            text: $viewModel.company,
                            textContentType: .organizationName,
                            icon: "building.2.fill"
                        )

                        // Email
                        ValidatedTextField(
                            title: "Email",
                            placeholder: "name@company.com",
                            text: $viewModel.email,
                            isValid: viewModel.isValidEmail,
                            keyboardType: .emailAddress,
                            textContentType: .emailAddress,
                            icon: "envelope.fill",
                            errorMessage: "Please enter a valid email address"
                        )
                        .onChange(of: viewModel.email) {
                            viewModel.validateEmail()
                        }

                        // Phone
                        ValidatedTextField(
                            title: "Phone",
                            placeholder: "+1 (555) 123-4567",
                            text: $viewModel.phoneNumber,
                            isValid: viewModel.isValidPhone,
                            keyboardType: .phonePad,
                            textContentType: .telephoneNumber,
                            icon: "phone.fill",
                            errorMessage: "Please enter a valid phone number"
                        )
                        .onChange(of: viewModel.phoneNumber) {
                            viewModel.validatePhone()
                        }

                        // Website
                        ValidatedTextField(
                            title: "Website",
                            placeholder: "https://company.com",
                            text: $viewModel.website,
                            isValid: viewModel.isValidWebsite,
                            keyboardType: .URL,
                            textContentType: .URL,
                            icon: "globe",
                            errorMessage: "Please enter a valid URL"
                        )
                        .onChange(of: viewModel.website) {
                            viewModel.validateWebsite()
                        }

                        // Address
                        ValidatedTextField(
                            title: "Address",
                            placeholder: "123 Main St, City, State 12345",
                            text: $viewModel.address,
                            textContentType: .fullStreetAddress,
                            icon: "location.fill"
                        )

                        // Notes
                        ValidatedTextEditor(
                            title: "Notes",
                            placeholder: "Add any additional notes about this contact...",
                            text: $viewModel.notes,
                            icon: "note.text",
                            minHeight: 100
                        )
                    }
                    .padding(.horizontal, 20)

                    // Action buttons
                    VStack(spacing: 12) {
                        PrimaryButton(
                            "Save to Database & Contacts",
                            systemImage: "person.crop.circle.badge.plus",
                            isLoading: viewModel.isSaving,
                            isDisabled: !viewModel.canSave
                        ) {
                            Task {
                                await viewModel.saveBoth()
                                if viewModel.saveError == nil {
                                    dismiss()
                                    onDismiss()
                                }
                            }
                        }

                        SecondaryButton(
                            "Save to Database Only",
                            systemImage: "square.and.arrow.down"
                        ) {
                            Task {
                                await viewModel.saveToDatabaseOnly()
                                if viewModel.saveError == nil {
                                    dismiss()
                                    onDismiss()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("New Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        HapticManager.shared.buttonTap()
                        dismiss()
                    }
                    .accessibilityLabel("Cancel")
                    .accessibilityHint("Discard this contact")
                }
            }
            .alert("Error Saving Contact", isPresented: .constant(viewModel.saveError != nil)) {
                Button("OK") {
                    viewModel.saveError = nil
                }
            } message: {
                if let error = viewModel.saveError {
                    Text(error)
                }
            }
            .alert("Contact Saved", isPresented: $viewModel.showSuccessAlert) {
                Button("Done") {
                    dismiss()
                    onDismiss()
                }
            } message: {
                Text("The business card has been saved successfully.")
            }
        }
        .onAppear {
            let databaseService = DatabaseService(modelContext: modelContext)
            viewModel.setDatabaseService(databaseService)
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Preview

#Preview("Contact Preview") {
    ContactPreviewView(
        scannedText: """
        Sarah Chen
        Senior Product Designer
        Acme Design Co
        sarah.chen@acme.design
        +1 (555) 123-4567
        https://acme.design
        """
    ) {
        AppLogger.ui.debug("Preview dismissed")
    }
    .modelContainer(for: BusinessCard.self, inMemory: true)
}

#Preview("Contact Preview - Empty") {
    ContactPreviewView(
        scannedText: ""
    ) {
        AppLogger.ui.debug("Preview dismissed")
    }
    .modelContainer(for: BusinessCard.self, inMemory: true)
}
