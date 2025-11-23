//
//  SettingsView.swift
//  OneBookAMonth
//
//  Settings screen with app information and actions
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // App Info Card
                    appInfoCard

                    // Action Buttons
                    actionButtons
                }
                .padding(Spacing.lg)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        // Reset Onboarding Confirmation
        .alert("Reset Onboarding?", isPresented: $viewModel.showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset") {
                viewModel.resetOnboarding()
            }
        } message: {
            Text("You'll see the welcome screens again the next time you open the app.")
        }
        // Reset Success Message
        .alert("Onboarding Reset", isPresented: $viewModel.showResetSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Close and reopen the app to see the onboarding flow.")
        }
    }

    // MARK: - App Info Card

    private var appInfoCard: some View {
        VStack(spacing: Spacing.md) {
            // App Icon
            Image("AppIconDisplay")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.large)
                        .stroke(Color.borderColor.opacity(0.2), lineWidth: 1)
                )

            // App Name
            Text("OneBookAMonth")
                .font(.displayMedium)
                .foregroundColor(.textPrimary)

            // Version Info
            Text(viewModel.versionText)
                .font(.bodySmall)
                .foregroundColor(.textSecondary)

            // Copyright
            Text(viewModel.copyrightText)
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .padding(Spacing.xl)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: Spacing.xs) {
            // Reset Onboarding
            Button(action: {
                viewModel.showResetAlert = true
            }) {
                SettingRow(
                    icon: "arrow.counterclockwise",
                    title: "Reset Onboarding"
                )
            }
            .buttonStyle(.plain)

            // Rate & Review
            Button(action: {
                viewModel.openAppStoreForReview()
            }) {
                SettingRow(
                    icon: "star.fill",
                    title: "Rate & Review"
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}
