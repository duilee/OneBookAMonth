//
//  Spacing.swift
//  OneBookAMonth
//
//  Design System - Spacing & Insets
//  8pt grid system for consistent layouts
//

import Foundation
import SwiftUI

// MARK: - Spacing (8pt Grid)
enum Spacing {
    static let xxs: CGFloat = 4   // Minimal spacing (badges, tight elements)
    static let xs: CGFloat = 8    // Tight spacing (progress tags)
    static let sm: CGFloat = 12   // Small spacing (list items, cards)
    static let md: CGFloat = 16   // Default spacing (standard gaps)
    static let lg: CGFloat = 20   // Large spacing (section spacing)
    static let xl: CGFloat = 24   // Extra large spacing (major sections)
    static let xxl: CGFloat = 32  // Huge spacing (page sections)
    static let xxxl: CGFloat = 40 // Maximum spacing (major dividers)
    static let massive: CGFloat = 48 // Horizontal page padding
}

// MARK: - Standard Insets
enum Insets {
    static let screenEdge: CGFloat = 20         // Screen edge padding
    static let screenHorizontal: CGFloat = 40   // Horizontal page padding
    static let cardPadding: CGFloat = 16        // Card internal padding
    static let buttonPadding: CGFloat = 12      // Button internal padding
    static let listItem: CGFloat = 12           // List item padding
    static let badge: CGFloat = 8               // Badge internal padding
}

// MARK: - Corner Radius
enum CornerRadius {
    static let tiny: CGFloat = 4        // Tiny elements (badges)
    static let small: CGFloat = 8       // Small elements
    static let medium: CGFloat = 12     // Default elements (buttons, cards)
    static let large: CGFloat = 16      // Large cards
    static let xlarge: CGFloat = 20     // Very large elements (modals)
    static let xxlarge: CGFloat = 24    // Huge elements
    static let circle: CGFloat = 28     // Circular elements (FAB)
}

// MARK: - Shadow
enum Shadow {
    // Shadow presets for consistent elevation
    static let small = (color: Color.black.opacity(0.08), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
    static let medium = (color: Color.black.opacity(0.1), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
    static let large = (color: Color.black.opacity(0.15), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
    static let fab = (color: Color.black.opacity(0.3), radius: CGFloat(3), x: CGFloat(0), y: CGFloat(2))
}

// MARK: - Preview
#Preview("Spacing Scale") {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            Text("Spacing Scale (8pt Grid)")
                .font(.headline)

            VStack(alignment: .leading, spacing: 16) {
                SpacingExample(value: Spacing.xxs, name: "XXS (4pt)")
                SpacingExample(value: Spacing.xs, name: "XS (8pt)")
                SpacingExample(value: Spacing.sm, name: "SM (12pt)")
                SpacingExample(value: Spacing.md, name: "MD (16pt)")
                SpacingExample(value: Spacing.lg, name: "LG (20pt)")
                SpacingExample(value: Spacing.xl, name: "XL (24pt)")
                SpacingExample(value: Spacing.xxl, name: "XXL (32pt)")
                SpacingExample(value: Spacing.xxxl, name: "XXXL (40pt)")
                SpacingExample(value: Spacing.massive, name: "Massive (48pt)")
            }

            Divider()
                .padding(.vertical)

            Text("Corner Radius Scale")
                .font(.headline)

            VStack(alignment: .leading, spacing: 16) {
                CornerExample(value: CornerRadius.tiny, name: "Tiny (4pt)")
                CornerExample(value: CornerRadius.small, name: "Small (8pt)")
                CornerExample(value: CornerRadius.medium, name: "Medium (12pt)")
                CornerExample(value: CornerRadius.large, name: "Large (16pt)")
                CornerExample(value: CornerRadius.xlarge, name: "XLarge (20pt)")
                CornerExample(value: CornerRadius.xxlarge, name: "XXLarge (24pt)")
                CornerExample(value: CornerRadius.circle, name: "Circle (28pt)")
            }

            Divider()
                .padding(.vertical)

            Text("Shadow Elevations")
                .font(.headline)

            VStack(spacing: 16) {
                ShadowExample(shadow: Shadow.small, name: "Small")
                ShadowExample(shadow: Shadow.medium, name: "Medium")
                ShadowExample(shadow: Shadow.large, name: "Large")
                ShadowExample(shadow: Shadow.fab, name: "FAB")
            }
        }
        .padding()
    }
}

// Helper views for preview
private struct SpacingExample: View {
    let value: CGFloat
    let name: String

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.primaryDeep)
                .frame(width: value, height: 20)
            Text(name)
                .font(.caption)
                .foregroundColor(.textSecondary)
            Spacer()
        }
    }
}

private struct CornerExample: View {
    let value: CGFloat
    let name: String

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: value)
                .fill(Color.primaryDeep)
                .frame(width: 60, height: 60)
            Text(name)
                .font(.caption)
                .foregroundColor(.textSecondary)
            Spacer()
        }
    }
}

private struct ShadowExample: View {
    let shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat)
    let name: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.caption)
                .foregroundColor(.textSecondary)
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .fill(Color.white)
                .frame(height: 60)
                .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
        }
    }
}
