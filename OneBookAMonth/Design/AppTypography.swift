//
//  AppTypography.swift
//  OneBookAMonth
//
//  Design System - Typography Scale
//  Using SF Pro with semantic font styles that support Dynamic Type
//

import SwiftUI

extension Font {
    // MARK: - Display Fonts (Large Headers)
    // For page titles and major headings
    static let displayLarge = Font.largeTitle.weight(.bold)         // ~34pt - main titles
    static let displayMedium = Font.title.weight(.bold)             // ~28pt - section titles
    static let displaySmall = Font.title2.weight(.bold)             // ~22pt - subsection titles

    // MARK: - Heading Fonts
    // For card titles and smaller headings
    static let headingLarge = Font.title3.weight(.semibold)         // ~20pt - card titles
    static let headingMedium = Font.headline.weight(.semibold)      // ~18pt - card headers
    static let headingSmall = Font.subheadline.weight(.semibold)    // ~16pt - small headers

    // MARK: - Body Fonts
    // For regular text content
    static let bodyLarge = Font.body.weight(.regular)               // ~17pt - primary content
    static let bodyMedium = Font.callout.weight(.regular)           // ~16pt - secondary content
    static let bodySmall = Font.subheadline.weight(.regular)        // ~15pt - tertiary content

    // MARK: - Label Fonts
    // For labels and captions
    static let labelLarge = Font.callout.weight(.medium)            // ~16pt - emphasized labels
    static let labelMedium = Font.subheadline.weight(.medium)       // ~15pt - regular labels
    static let labelSmall = Font.footnote.weight(.medium)           // ~13pt - small labels
    static let labelTiny = Font.caption.weight(.medium)             // ~12pt - tiny labels

    // MARK: - Special Purpose Fonts
    // For specific UI elements
    static let buttonLabel = Font.headline.weight(.semibold)        // Buttons
    static let tabLabel = Font.caption2.weight(.medium)             // Tab bar labels
    static let badgeLabel = Font.caption.weight(.bold)              // Progress badges
    static let statisticNumber = Font.system(size: 80, weight: .black) // Large numbers
    static let loadingEmoji = Font.system(size: 80)                 // Loading animation

    // MARK: - Book-Specific Fonts
    // Semantic fonts for book-related UI
    static let bookTitle = Font.headline.weight(.semibold)          // Book titles
    static let bookAuthor = Font.subheadline.weight(.medium)        // Author names
    static let bookPages = Font.footnote.weight(.regular)           // Page counts
    static let bookProgress = Font.caption.weight(.bold)            // Progress text

    // MARK: - Challenge-Specific Fonts
    // Semantic fonts for challenge UI
    static let challengeTitle = Font.title2.weight(.bold)           // Challenge names
    static let challengeStatus = Font.caption.weight(.bold)         // Status badges
    static let challengeStats = Font.body.weight(.medium)           // Statistics
}

// MARK: - Preview
#Preview("Typography Scale") {
    ScrollView {
        VStack(alignment: .leading, spacing: 32) {
            // Display Fonts
            TypeSection(title: "Display Fonts") {
                TypeExample(font: .displayLarge, text: "Display Large", description: "Main titles")
                TypeExample(font: .displayMedium, text: "Display Medium", description: "Section titles")
                TypeExample(font: .displaySmall, text: "Display Small", description: "Subsection titles")
            }

            // Heading Fonts
            TypeSection(title: "Heading Fonts") {
                TypeExample(font: .headingLarge, text: "Heading Large", description: "Card titles")
                TypeExample(font: .headingMedium, text: "Heading Medium", description: "Card headers")
                TypeExample(font: .headingSmall, text: "Heading Small", description: "Small headers")
            }

            // Body Fonts
            TypeSection(title: "Body Fonts") {
                TypeExample(font: .bodyLarge, text: "Body Large", description: "Primary content")
                TypeExample(font: .bodyMedium, text: "Body Medium", description: "Secondary content")
                TypeExample(font: .bodySmall, text: "Body Small", description: "Tertiary content")
            }

            // Label Fonts
            TypeSection(title: "Label Fonts") {
                TypeExample(font: .labelLarge, text: "Label Large", description: "Emphasized labels")
                TypeExample(font: .labelMedium, text: "Label Medium", description: "Regular labels")
                TypeExample(font: .labelSmall, text: "Label Small", description: "Small labels")
                TypeExample(font: .labelTiny, text: "Label Tiny", description: "Tiny labels")
            }

            // Special Purpose
            TypeSection(title: "Special Purpose") {
                TypeExample(font: .buttonLabel, text: "Button Label", description: "Buttons")
                TypeExample(font: .badgeLabel, text: "BADGE", description: "Progress badges")
            }

            // Book-Specific
            TypeSection(title: "Book UI") {
                TypeExample(font: .bookTitle, text: "The Great Gatsby", description: "Book titles")
                TypeExample(font: .bookAuthor, text: "F. Scott Fitzgerald", description: "Author names")
                TypeExample(font: .bookPages, text: "180 pages", description: "Page counts")
                TypeExample(font: .bookProgress, text: "75% COMPLETE", description: "Progress")
            }
        }
        .padding()
    }
}

// Helper views for preview
private struct TypeSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .textCase(.uppercase)
            content
            Divider()
        }
    }
}

private struct TypeExample: View {
    let font: Font
    let text: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .font(font)
            Text(description)
                .font(.caption2)
                .foregroundColor(.textTertiary)
        }
    }
}
