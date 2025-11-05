//
//  ValidatedTextField.swift
//  Deets
//
//  Text field with validation indicators
//

import SwiftUI

struct ValidatedTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isValid: Bool = true
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var icon: String?
    var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            // Text field
            HStack(spacing: 12) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundStyle(isValid ? .secondary : .red)
                        .frame(width: 20)
                        .accessibilityHidden(true)
                }

                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .accessibilityLabel(title)
                    .accessibilityValue(text.isEmpty ? "Empty" : text)
                    .accessibilityHint(placeholder)

                if !text.isEmpty {
                    if isValid {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.body)
                            .foregroundStyle(.green)
                            .accessibilityLabel("Valid")
                    } else {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.body)
                            .foregroundStyle(.red)
                            .accessibilityLabel("Invalid")
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        !text.isEmpty && !isValid ? Color.red.opacity(0.5) : Color.clear,
                        lineWidth: 1
                    )
            )

            // Error message
            if !isValid, let errorMessage, !text.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .accessibilityLabel("Error: \(errorMessage)")
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isValid)
    }
}

// MARK: - Multi-line Text Field

struct ValidatedTextEditor: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var icon: String?
    var minHeight: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            // Text editor
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }

                TextEditor(text: $text)
                    .frame(minHeight: minHeight)
                    .scrollContentBackground(.hidden)
                    .accessibilityLabel(title)
                    .accessibilityValue(text.isEmpty ? "Empty" : text)
                    .accessibilityHint(placeholder)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

// MARK: - Preview

#Preview("Text Fields") {
    struct PreviewWrapper: View {
        @State private var email = "test@example.com"
        @State private var phone = "555-1234"
        @State private var invalidEmail = "invalid"
        @State private var notes = ""

        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    ValidatedTextField(
                        title: "Email",
                        placeholder: "name@company.com",
                        text: $email,
                        isValid: true,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        icon: "envelope.fill"
                    )

                    ValidatedTextField(
                        title: "Phone",
                        placeholder: "+1 (555) 123-4567",
                        text: $phone,
                        isValid: true,
                        keyboardType: .phonePad,
                        textContentType: .telephoneNumber,
                        icon: "phone.fill"
                    )

                    ValidatedTextField(
                        title: "Email",
                        placeholder: "name@company.com",
                        text: $invalidEmail,
                        isValid: false,
                        keyboardType: .emailAddress,
                        icon: "envelope.fill",
                        errorMessage: "Please enter a valid email address"
                    )

                    ValidatedTextEditor(
                        title: "Notes",
                        placeholder: "Add notes about this contact...",
                        text: $notes,
                        icon: "note.text"
                    )
                }
                .padding()
            }
        }
    }

    return PreviewWrapper()
}
