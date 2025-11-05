//
//  OnboardingView.swift
//  Deets
//
//  Welcome and feature introduction flow for first-time users
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var currentPage = 0
    @State private var showPermissions = false

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            systemImage: "camera.viewfinder",
            color: .teal,
            title: L10n.Onboarding.Feature1.title,
            message: L10n.Onboarding.Feature1.message
        ),
        OnboardingPage(
            systemImage: "hand.tap.fill",
            color: .blue,
            title: L10n.Onboarding.Feature2.title,
            message: L10n.Onboarding.Feature2.message
        ),
        OnboardingPage(
            systemImage: "person.2.fill",
            color: .purple,
            title: L10n.Onboarding.Feature3.title,
            message: L10n.Onboarding.Feature3.message
        ),
        OnboardingPage(
            systemImage: "lock.shield.fill",
            color: .green,
            title: L10n.Onboarding.Privacy.title,
            message: L10n.Onboarding.Privacy.message
        )
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.teal.opacity(0.05),
                    Color.blue.opacity(0.05),
                    Color.purple.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()

                    Button {
                        HapticManager.shared.buttonTap()
                        skipOnboarding()
                    } label: {
                        Text(L10n.Onboarding.Button.skip)
                            .font(.body.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel(L10n.Onboarding.Button.skip)
                    .accessibilityHint("Skip onboarding and go to main app")
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Content
                TabView(selection: $currentPage) {
                    // Welcome page
                    WelcomePage()
                        .tag(0)

                    // Feature pages
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        PageView(page: page)
                            .tag(index + 1)
                    }

                    // Privacy details page
                    PrivacyPage()
                        .tag(pages.count + 1)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .animation(reduceMotion ? .none : .easeInOut, value: currentPage)

                // Navigation buttons
                VStack(spacing: 16) {
                    if isLastPage {
                        // Get Started button
                        PrimaryButton(
                            L10n.Onboarding.Button.getStarted,
                            systemImage: "arrow.right"
                        ) {
                            HapticManager.shared.success()
                            completeOnboarding()
                        }
                        .padding(.horizontal, 24)
                    } else {
                        // Next button
                        Button {
                            HapticManager.shared.buttonTap()
                            withAnimation(reduceMotion ? .none : .default) {
                                currentPage += 1
                            }
                        } label: {
                            HStack {
                                Text(L10n.Onboarding.Button.next)
                                    .font(.body.weight(.semibold))

                                Image(systemName: "arrow.right")
                                    .font(.body.weight(.semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.teal)
                            )
                        }
                        .padding(.horizontal, 24)
                        .accessibilityLabel(L10n.Onboarding.Button.next)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showPermissions) {
            PermissionsView {
                completeOnboarding()
            }
        }
    }

    private var isLastPage: Bool {
        currentPage == pages.count + 1
    }

    private func skipOnboarding() {
        hasCompletedOnboarding = true
        dismiss()
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
        dismiss()
    }
}

// MARK: - Welcome Page

private struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // App icon placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color.teal, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .black.opacity(0.1), radius: 20, y: 10)

                Image(systemName: "person.text.rectangle.fill")
                    .iconMedium()
                    .foregroundStyle(.white)
            }

            VStack(spacing: 12) {
                Text(L10n.Onboarding.welcomeTitle)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(L10n.App.tagline)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Color.teal)
                    .multilineTextAlignment(.center)

                Text(L10n.Onboarding.welcomeMessage)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }
}

// MARK: - Feature Page

private struct PageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 140, height: 140)

                Image(systemName: page.systemImage)
                    .iconMediumLarge()
                    .foregroundStyle(page.color)
                    .accessibilityHidden(true)
            }

            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(page.message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }
}

// MARK: - Privacy Page

private struct PrivacyPage: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer()
                    .frame(height: 40)

                // Lock icon
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 140, height: 140)

                    Image(systemName: "lock.shield.fill")
                        .iconMediumLarge()
                        .foregroundStyle(.green)
                        .accessibilityHidden(true)
                }

                // Privacy promise
                VStack(spacing: 16) {
                    Text(L10n.Onboarding.Privacy.title)
                        .font(.title.weight(.bold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)

                    Text(L10n.Onboarding.Privacy.detail)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 32)

                // Privacy features
                VStack(spacing: 16) {
                    PrivacyFeature(
                        icon: "iphone",
                        title: "On-Device Processing",
                        description: "All scanning happens on your iPhone"
                    )

                    PrivacyFeature(
                        icon: "cloud.slash.fill",
                        title: "No Cloud Uploads",
                        description: "Your contacts never leave your device"
                    )

                    PrivacyFeature(
                        icon: "eye.slash.fill",
                        title: "No Tracking",
                        description: "We don't collect, analyze, or sell your data"
                    )
                }
                .padding(.horizontal, 24)

                Spacer()
                    .frame(height: 40)
            }
        }
    }
}

// MARK: - Privacy Feature Row

private struct PrivacyFeature: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.green)
                .frame(width: 32)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Permissions View

private struct PermissionsView: View {
    @Environment(\.dismiss) private var dismiss
    let onComplete: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Icon
                Image(systemName: "hand.raised.fill")
                    .iconMediumLarge()
                    .foregroundStyle(Color.teal)
                    .accessibilityHidden(true)

                // Title and message
                VStack(spacing: 12) {
                    Text(L10n.Onboarding.Permissions.title)
                        .font(.title.weight(.bold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)

                    Text("Deets works best with these permissions, but they're optional.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)

                // Permission cards
                VStack(spacing: 16) {
                    PermissionCard(
                        icon: "camera.fill",
                        color: .teal,
                        title: "Camera",
                        description: L10n.Onboarding.Permissions.camera
                    )

                    PermissionCard(
                        icon: "person.crop.circle.badge.plus",
                        color: .blue,
                        title: "Contacts",
                        description: L10n.Onboarding.Permissions.contacts
                    )
                }
                .padding(.horizontal, 24)

                Spacer()

                // Action button
                PrimaryButton(
                    L10n.Onboarding.Button.done,
                    systemImage: "checkmark"
                ) {
                    HapticManager.shared.success()
                    dismiss()
                    onComplete()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Permission Card

private struct PermissionCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Supporting Types

private struct OnboardingPage {
    let systemImage: String
    let color: Color
    let title: String
    let message: String
}

// MARK: - Preview

#Preview("Onboarding") {
    OnboardingView()
}
