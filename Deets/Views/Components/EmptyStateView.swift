//
//  EmptyStateView.swift
//  Deets
//
//  Reusable empty state component
//

import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: systemImage)
                .iconLarge()
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            if let actionTitle, let action {
                Button(action: {
                    HapticManager.shared.buttonTap()
                    action()
                }) {
                    Text(actionTitle)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.teal)
                        )
                }
                .padding(.top, 8)
                .accessibilityLabel(actionTitle)
                .accessibilityHint("Double tap to \(actionTitle.lowercased())")
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
}

// MARK: - Preview

#Preview("Empty States") {
    TabView {
        EmptyStateView(
            systemImage: "rectangle.stack.badge.plus",
            title: "No Business Cards Yet",
            message: "Scan your first business card to get started. It only takes a moment!",
            actionTitle: "Scan First Card"
        ) {
            AppLogger.ui.debug("Preview: Start scanning action triggered")
        }
        .tabItem {
            Label("With Action", systemImage: "1.circle")
        }

        EmptyStateView(
            systemImage: "magnifyingglass",
            title: "No Results Found",
            message: "Try adjusting your search or filters to find what you're looking for."
        )
        .tabItem {
            Label("No Action", systemImage: "2.circle")
        }
    }
}
