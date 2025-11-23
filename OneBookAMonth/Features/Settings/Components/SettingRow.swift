//
//  SettingRow.swift
//  OneBookAMonth
//
//  Reusable setting row component
//

import SwiftUI

struct SettingRow: View {
    let icon: String
    let title: String
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.headingMedium)
                .foregroundColor(.primaryDeep)
                .frame(width: 24)

            Text(title)
                .font(.bodyMedium)
                .foregroundColor(.textPrimary)

            Spacer()

            if showChevron {
                Image(systemName: AppIcon.forward)
                    .font(.labelSmall)
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(Spacing.md)
        .background(Color.surfaceColor)
        .cornerRadius(CornerRadius.medium)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: Spacing.sm) {
        Button(action: {}) {
            SettingRow(
                icon: "arrow.counterclockwise",
                title: "Reset Onboarding"
            )
        }
        .buttonStyle(.plain)

        Button(action: {}) {
            SettingRow(
                icon: "star.fill",
                title: "Rate & Review"
            )
        }
        .buttonStyle(.plain)
    }
    .padding()
    .background(Color.backgroundPrimary)
}
