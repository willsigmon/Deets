//
//  PrimaryButton.swift
//  Deets
//
//  Reusable primary button component
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false

    init(
        _ title: String,
        systemImage: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.body.weight(.semibold))
                }

                Text(title)
                    .font(.body.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.teal)
                    .opacity(isDisabled ? 0.5 : 1)
            )
            .foregroundStyle(.white)
        }
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(title)
        .accessibilityHint(isLoading ? "Loading" : "Double tap to activate")
        .accessibilityAddTraits(isDisabled ? .isButton : [.isButton])
    }
}

// MARK: - Secondary Button

struct SecondaryButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void
    var isDisabled: Bool = false

    init(
        _ title: String,
        systemImage: String? = nil,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.buttonTap()
            action()
        }) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.body.weight(.medium))
                }

                Text(title)
                    .font(.body.weight(.medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .opacity(isDisabled ? 0.5 : 1)
            )
            .foregroundStyle(Color.primary)
        }
        .disabled(isDisabled)
        .accessibilityLabel(title)
        .accessibilityHint("Double tap to activate")
    }
}

// MARK: - Preview

#Preview("Buttons") {
    VStack(spacing: 20) {
        PrimaryButton("Save Contact", systemImage: "person.crop.circle.badge.plus") {}

        PrimaryButton("Loading...", isLoading: true) {}

        PrimaryButton("Disabled", isDisabled: true) {}

        SecondaryButton("Cancel", systemImage: "xmark") {}
    }
    .padding()
}
