//
//  AppColors.swift
//  OneBookAMonth
//
//  Design System - Color Palette
//  Book reading focused color scheme
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors
    static let primaryDeep = Color(red: 25/255, green: 45/255, blue: 155/255)      // Deep Blue - primary actions
    static let primaryMedium = Color(red: 100/255, green: 110/255, blue: 190/255)   // Medium Blue - secondary
    static let primaryLight = Color(red: 150/255, green: 160/255, blue: 220/255)    // Light Blue - accents

    // MARK: - Semantic Colors
    static let accentBlue = Color.blue                              // System blue for highlights
    static let accentCoral = Color(red: 1.0, green: 0.42, blue: 0.42) // Coral (#FF6B6B) - loading states
    static let successGreen = Color(hex: "34C759")                  // iOS Green - success
    static let errorRed = Color(hex: "FF3B30")                      // iOS Red - errors
    static let warningOrange = Color(hex: "FF9500")                 // iOS Orange - warnings

    // MARK: - Neutral Colors
    static let backgroundPrimary = Color(hex: "F9FAFB")             // Light gray background
    static let backgroundSecondary = Color(hex: "F3F4F6")           // Slightly darker gray
    static let surfaceColor = Color.white                           // Card/surface backgrounds
    static let textPrimary = Color(hex: "111827")                   // Almost black
    static let textSecondary = Color(hex: "6B7280")                 // Medium gray
    static let textTertiary = Color(hex: "9CA3AF")                  // Light gray
    static let borderColor = Color(hex: "E5E7EB")                   // Light border
    static let dividerColor = Color(hex: "D1D5DB")                  // Divider lines

    // MARK: - Overlay Colors
    static let overlayDark = Color.black.opacity(0.6)
    static let overlayMedium = Color.black.opacity(0.4)
    static let overlayLight = Color.black.opacity(0.1)
    static let shimmerOverlay = Color.white.opacity(0.3)

    // MARK: - Status Colors (for challenges)
    static let statusPending = Color(hex: "F59E0B")                 // Amber
    static let statusActive = Color(hex: "10B981")                  // Green
    static let statusCompleted = Color(hex: "3B82F6")               // Blue
    static let statusFailed = Color(hex: "EF4444")                  // Red

    // MARK: - Hex Color Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview("Color Palette") {
    ScrollView {
        VStack(spacing: 24) {
            // Primary Colors
            VStack(alignment: .leading, spacing: 12) {
                Text("Primary Colors")
                    .font(.headline)
                HStack(spacing: 12) {
                    ColorSwatch(color: .primaryDeep, name: "Deep")
                    ColorSwatch(color: .primaryMedium, name: "Medium")
                    ColorSwatch(color: .primaryLight, name: "Light")
                }
            }

            // Semantic Colors
            VStack(alignment: .leading, spacing: 12) {
                Text("Semantic Colors")
                    .font(.headline)
                HStack(spacing: 12) {
                    ColorSwatch(color: .successGreen, name: "Success")
                    ColorSwatch(color: .errorRed, name: "Error")
                    ColorSwatch(color: .warningOrange, name: "Warning")
                }
            }

            // Neutral Colors
            VStack(alignment: .leading, spacing: 12) {
                Text("Neutral Colors")
                    .font(.headline)
                VStack(spacing: 8) {
                    ColorRow(color: .textPrimary, name: "Text Primary")
                    ColorRow(color: .textSecondary, name: "Text Secondary")
                    ColorRow(color: .textTertiary, name: "Text Tertiary")
                    ColorRow(color: .borderColor, name: "Border")
                }
            }

            // Status Colors
            VStack(alignment: .leading, spacing: 12) {
                Text("Status Colors")
                    .font(.headline)
                HStack(spacing: 12) {
                    ColorSwatch(color: .statusPending, name: "Pending")
                    ColorSwatch(color: .statusActive, name: "Active")
                    ColorSwatch(color: .statusCompleted, name: "Completed")
                    ColorSwatch(color: .statusFailed, name: "Failed")
                }
            }
        }
        .padding()
    }
}

// Helper views for preview
private struct ColorSwatch: View {
    let color: Color
    let name: String

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 80, height: 80)
            Text(name)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

private struct ColorRow: View {
    let color: Color
    let name: String

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 40, height: 40)
            Text(name)
                .font(.body)
            Spacer()
        }
    }
}
