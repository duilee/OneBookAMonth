//
//  ButtonStyles.swift
//  OneBookAMonth
//
//  Design System - Button Styles
//  Consistent button styling across the app
//

import SwiftUI

// MARK: - Primary Button
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.buttonLabel)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 50)
            .padding(.vertical, Spacing.xxs)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(configuration.isPressed ? Color.primaryDeep.opacity(0.8) : Color.primaryDeep)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.buttonLabel)
            .foregroundColor(.primaryDeep)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 50)
            .padding(.vertical, Spacing.xxs)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .strokeBorder(Color.primaryDeep, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.medium)
                            .fill(configuration.isPressed ? Color.backgroundSecondary : Color.clear)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Accent Button (for highlighted actions)
struct AccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.buttonLabel)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 50)
            .padding(.vertical, Spacing.xxs)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(configuration.isPressed ? Color.accentBlue.opacity(0.8) : Color.accentBlue)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Destructive Button
struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.labelMedium)
            .foregroundColor(.errorRed)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .strokeBorder(Color.errorRed.opacity(0.3), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

// MARK: - Text Button
struct TextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyMedium)
            .foregroundColor(.primaryDeep)
            .padding(Spacing.sm)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

// MARK: - Compact Button (for small CTAs)
struct CompactButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.labelMedium)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .fill(configuration.isPressed ? Color.primaryDeep.opacity(0.8) : Color.primaryDeep)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview("All Button Styles") {
    ScrollView {
        VStack(spacing: 32) {
            Text("OneBookAMonth Button Styles")
                .font(.displayMedium)
                .padding(.bottom)

            // Primary Button
            VStack(alignment: .leading, spacing: 8) {
                Text("Primary Button")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Button("Add Book") {}
                    .buttonStyle(PrimaryButtonStyle())
            }

            // Secondary Button
            VStack(alignment: .leading, spacing: 8) {
                Text("Secondary Button")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Button("Cancel") {}
                    .buttonStyle(SecondaryButtonStyle())
            }

            // Accent Button
            VStack(alignment: .leading, spacing: 8) {
                Text("Accent Button")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Button("Start Challenge") {}
                    .buttonStyle(AccentButtonStyle())
            }

            // Compact Button
            VStack(alignment: .leading, spacing: 8) {
                Text("Compact Button")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Button("Add Note") {}
                    .buttonStyle(CompactButtonStyle())
            }

            // Destructive Button
            VStack(alignment: .leading, spacing: 8) {
                Text("Destructive Button")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Button("Delete Book") {}
                    .buttonStyle(DestructiveButtonStyle())
            }

            // Text Button
            VStack(alignment: .leading, spacing: 8) {
                Text("Text Button")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Button("Learn More") {}
                    .buttonStyle(TextButtonStyle())
            }
        }
        .padding(24)
    }
    .background(Color.backgroundPrimary)
}

#Preview("Button Combinations") {
    ScrollView {
        VStack(spacing: 32) {
            Text("Common Button Patterns")
                .font(.headingLarge)
                .padding(.bottom)

            // Form Submission Pattern
            VStack(spacing: 12) {
                Text("Form Submission")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Button("Save Book") {}
                    .buttonStyle(PrimaryButtonStyle())

                Button("Cancel") {}
                    .buttonStyle(SecondaryButtonStyle())
            }

            Divider()

            // Challenge Creation
            VStack(spacing: 12) {
                Text("Challenge Creation")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Button("Start Challenge") {}
                    .buttonStyle(AccentButtonStyle())

                Button("Set Reminder") {}
                    .buttonStyle(SecondaryButtonStyle())
            }

            Divider()

            // Destructive with Context
            VStack(spacing: 12) {
                Text("Deleting this book will remove all progress")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)

                Button("Delete Book") {}
                    .buttonStyle(DestructiveButtonStyle())

                Button("Keep Book") {}
                    .buttonStyle(TextButtonStyle())
            }

            Divider()

            // Inline Actions
            HStack(spacing: 12) {
                Button("Add Memo") {}
                    .buttonStyle(CompactButtonStyle())

                Button("Take Photo") {}
                    .buttonStyle(CompactButtonStyle())
            }
        }
        .padding(24)
    }
    .background(Color.backgroundPrimary)
}

#Preview("Disabled States") {
    VStack(spacing: 20) {
        Text("Disabled Button States")
            .font(.headingLarge)
            .padding(.bottom)

        Button("Add Book (Disabled)") {}
            .buttonStyle(PrimaryButtonStyle())
            .disabled(true)
            .opacity(0.5)

        Button("Cancel (Disabled)") {}
            .buttonStyle(SecondaryButtonStyle())
            .disabled(true)
            .opacity(0.5)

        Button("Start Challenge (Disabled)") {}
            .buttonStyle(AccentButtonStyle())
            .disabled(true)
            .opacity(0.5)
    }
    .padding(24)
    .background(Color.backgroundPrimary)
}
