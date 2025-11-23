//
//  ViewModifiers.swift
//  OneBookAMonth
//
//  Design System - View Modifiers
//  Reusable view modifiers for consistent styling
//

import SwiftUI

// MARK: - Card Style
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Insets.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.surfaceColor)
                    .shadow(color: Shadow.medium.color, radius: Shadow.medium.radius,
                           x: Shadow.medium.x, y: Shadow.medium.y)
            )
    }
}

// MARK: - Section Style
struct SectionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Insets.cardPadding)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .fill(Color.backgroundSecondary)
            )
    }
}

// MARK: - Badge Style
struct BadgeStyle: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(.badgeLabel)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xxs)
            .background(
                Capsule()
                    .fill(color)
            )
    }
}

// MARK: - Progress Card Style (for book cards with shadows)
struct ProgressCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .fill(Color.surfaceColor)
                    .shadow(color: Shadow.small.color, radius: Shadow.small.radius,
                           x: Shadow.small.x, y: Shadow.small.y)
            )
    }
}

// MARK: - Stat Card Style (for statistics displays)
struct StatCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.large)
                    .fill(Color.surfaceColor)
                    .shadow(color: Shadow.medium.color, radius: Shadow.medium.radius,
                           x: Shadow.medium.x, y: Shadow.medium.y)
            )
    }
}

// MARK: - View Extension for Easy Access
extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }

    func sectionStyle() -> some View {
        modifier(SectionStyle())
    }

    func badgeStyle(color: Color = .primaryDeep) -> some View {
        modifier(BadgeStyle(color: color))
    }

    func progressCardStyle() -> some View {
        modifier(ProgressCardStyle())
    }

    func statCardStyle() -> some View {
        modifier(StatCardStyle())
    }
}

// MARK: - Preview
#Preview("Card Style") {
    ScrollView {
        VStack(spacing: 20) {
            // Simple card
            VStack(alignment: .leading, spacing: 12) {
                Text("Add Your First Book")
                    .font(.headingMedium)

                Text("Track your reading progress and build a habit of reading one book per month.")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)

                Button("Add Book") {}
                    .buttonStyle(PrimaryButtonStyle())
            }
            .cardStyle()

            // Card with stats
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: AppIcon.bookFilled)
                        .font(.title)
                        .foregroundColor(.primaryDeep)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("The Great Gatsby")
                            .font(.bookTitle)
                        Text("F. Scott Fitzgerald")
                            .font(.bookAuthor)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()

                    Text("75%")
                        .badgeStyle(color: .statusActive)
                }

                ProgressView(value: 0.75)
                    .tint(.primaryDeep)
            }
            .cardStyle()
        }
        .padding()
    }
    .background(Color.backgroundPrimary)
}

#Preview("Section Style") {
    ScrollView {
        VStack(spacing: 20) {
            // Simple section
            VStack(alignment: .leading, spacing: 8) {
                Text("Reading Progress")
                    .font(.labelMedium)
                    .foregroundColor(.textSecondary)

                HStack {
                    Text("Pages Read")
                        .font(.bodyMedium)
                    Spacer()
                    Text("135 / 180")
                        .font(.headingSmall)
                        .foregroundColor(.primaryDeep)
                }

                HStack {
                    Text("Daily Goal")
                        .font(.bodyMedium)
                    Spacer()
                    Text("15 pages")
                        .font(.headingSmall)
                        .foregroundColor(.statusActive)
                }
            }
            .sectionStyle()

            // Section with icon
            HStack(spacing: 16) {
                Image(systemName: AppIcon.lightbulb)
                    .font(.title2)
                    .foregroundColor(.warningOrange)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Reading Tip")
                        .font(.labelLarge)

                    Text("Try reading at the same time each day to build a consistent habit.")
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                }
            }
            .sectionStyle()
        }
        .padding()
    }
    .background(Color.backgroundPrimary)
}

#Preview("Badge Styles") {
    VStack(spacing: 20) {
        Text("Badge Variations")
            .font(.displaySmall)
            .padding(.bottom)

        HStack(spacing: 12) {
            Text("ONGOING")
                .badgeStyle(color: .statusPending)

            Text("ACTIVE")
                .badgeStyle(color: .statusActive)

            Text("COMPLETED")
                .badgeStyle(color: .statusCompleted)
        }

        HStack(spacing: 12) {
            Text("75% DONE")
                .badgeStyle(color: .primaryDeep)

            Text("ON TRACK")
                .badgeStyle(color: .successGreen)

            Text("FAILED")
                .badgeStyle(color: .statusFailed)
        }
    }
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Stat Card Style") {
    ScrollView {
        VStack(spacing: 20) {
            // Monthly stats
            VStack(spacing: 16) {
                Text("This Month")
                    .font(.headingMedium)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 32) {
                    VStack(spacing: 4) {
                        Text("3")
                            .font(.displayMedium)
                            .foregroundColor(.primaryDeep)
                        Text("Books")
                            .font(.labelSmall)
                            .foregroundColor(.textSecondary)
                    }

                    VStack(spacing: 4) {
                        Text("847")
                            .font(.displayMedium)
                            .foregroundColor(.primaryDeep)
                        Text("Pages")
                            .font(.labelSmall)
                            .foregroundColor(.textSecondary)
                    }

                    VStack(spacing: 4) {
                        Text("23")
                            .font(.displayMedium)
                            .foregroundColor(.primaryDeep)
                        Text("Days")
                            .font(.labelSmall)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .statCardStyle()

            // Challenge progress
            VStack(spacing: 12) {
                HStack {
                    Text("Current Challenge")
                        .font(.headingSmall)
                    Spacer()
                    Text("ON TRACK")
                        .badgeStyle(color: .statusActive)
                }

                Text("Read 500 pages this month")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ProgressView(value: 0.68)
                    .tint(.statusActive)

                HStack {
                    Text("340 / 500 pages")
                        .font(.labelSmall)
                        .foregroundColor(.textSecondary)
                    Spacer()
                    Text("68%")
                        .font(.labelMedium)
                        .foregroundColor(.primaryDeep)
                }
            }
            .statCardStyle()
        }
        .padding()
    }
    .background(Color.backgroundPrimary)
}

#Preview("Combined Styles") {
    ScrollView {
        VStack(spacing: 24) {
            Text("View Modifiers Demo")
                .font(.displayMedium)
                .padding(.top)

            // Main card with sections
            VStack(spacing: 16) {
                HStack {
                    Text("Book Summary")
                        .font(.headingLarge)
                    Spacer()
                    Text("READING")
                        .badgeStyle(color: .statusActive)
                }

                VStack(spacing: 12) {
                    HStack {
                        Text("Progress")
                        Spacer()
                        Text("75%")
                            .foregroundColor(.statusActive)
                    }
                    .sectionStyle()

                    HStack {
                        Text("Pages Read")
                        Spacer()
                        Text("135 / 180")
                            .foregroundColor(.primaryDeep)
                    }
                    .sectionStyle()

                    HStack {
                        Text("Days Reading")
                        Spacer()
                        Text("12 days")
                            .foregroundColor(.textSecondary)
                    }
                    .sectionStyle()
                }

                Button("Add Reading Session") {}
                    .buttonStyle(PrimaryButtonStyle())
            }
            .cardStyle()
        }
        .padding()
    }
    .background(Color.backgroundPrimary)
}
