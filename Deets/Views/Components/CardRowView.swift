//
//  CardRowView.swift
//  Deets
//
//  Reusable business card row component
//

import SwiftUI

struct CardRowView: View {
    let card: BusinessCard
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 16) {
            // Avatar circle with initials
            ZStack {
                Circle()
                    .fill(Color.teal.opacity(0.15))
                    .frame(width: 48, height: 48)

                Text(card.fullName.prefix(1).uppercased())
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.teal)
            }
            .accessibilityHidden(true)

            // Card info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(card.displayName)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)

                    if card.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                            .accessibilityLabel("Favorite")
                    }

                    if card.savedToContacts {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .accessibilityLabel("Saved to contacts")
                    }
                }

                if let subtitle = card.displaySubtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Contact info badges
                HStack(spacing: 8) {
                    if card.email != nil {
                        ContactBadge(systemImage: "envelope.fill")
                    }

                    if card.phoneNumber != nil {
                        ContactBadge(systemImage: "phone.fill")
                    }

                    if card.website != nil {
                        ContactBadge(systemImage: "globe")
                    }
                }
            }

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view details")
    }

    private var accessibilityLabel: String {
        var label = card.displayName
        if let subtitle = card.displaySubtitle {
            label += ", \(subtitle)"
        }
        if card.isFavorite {
            label += ", Favorite"
        }
        if card.savedToContacts {
            label += ", Saved to contacts"
        }
        return label
    }
}

// MARK: - Contact Badge

private struct ContactBadge: View {
    let systemImage: String

    var body: some View {
        Image(systemName: systemImage)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(width: 20, height: 20)
            .background(
                Circle()
                    .fill(Color(.systemGray6))
            )
            .accessibilityHidden(true)
    }
}

// MARK: - Preview

#Preview("Card Rows") {
    NavigationStack {
        List {
            ForEach(BusinessCard.sampleData) { card in
                CardRowView(card: card)
            }
        }
        .navigationTitle("Business Cards")
    }
}
