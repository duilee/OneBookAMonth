//
//  AppIcons.swift
//  OneBookAMonth
//
//  Design System - SF Symbols Icon Library
//  Centralized icon definitions for consistent usage
//

import Foundation

enum AppIcon {
    // MARK: - Navigation
    static let add = "plus"
    static let close = "xmark.circle.fill"
    static let back = "chevron.left"
    static let forward = "chevron.right"
    static let expand = "chevron.down"

    // MARK: - Books
    static let book = "book"
    static let bookFilled = "book.fill"
    static let bookCircle = "book.circle"
    static let bookPages = "book.pages.fill"
    static let openBook = "book.pages"

    // MARK: - Camera & Photos
    static let camera = "camera.fill"
    static let photo = "photo"
    static let photos = "photo.on.rectangle"

    // MARK: - Status & Completion
    static let checkmark = "checkmark.circle"
    static let checkmarkFilled = "checkmark.circle.fill"
    static let complete = "checkmark.circle.fill"
    static let target = "target"
    static let trophy = "trophy"
    static let sparkles = "sparkles"

    // MARK: - Progress & Time
    static let timer = "timer"
    static let calendar = "calendar"
    static let speedometer = "speedometer"
    static let clock = "clock.fill"

    // MARK: - Timer Controls
    static let play = "play.fill"
    static let pause = "pause.fill"
    static let stop = "stop.fill"

    // MARK: - Stats & Charts
    static let chartBar = "chart.bar"
    static let chartBarFilled = "chart.bar.fill"
    static let statistics = "chart.line.uptrend.xyaxis"

    // MARK: - Actions
    static let edit = "pencil.circle.fill"
    static let delete = "trash"
    static let addNote = "note.text.badge.plus"
    static let addCircle = "plus.circle.fill"

    // MARK: - System Indicators
    static let sun = "sun.max.fill"
    static let battery = "battery.25"
    static let wifi = "iphone.radiowaves.left.and.right"
    static let lightbulb = "lightbulb.fill"

    // MARK: - Tab Bar Icons
    static let libraryTab = "books.vertical.fill"
    static let challengeTab = "target"
    static let statsTab = "chart.bar.fill"
}

// MARK: - Preview
#Preview("Icon Library") {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            // Navigation
            IconSection(title: "Navigation") {
                IconExample(name: AppIcon.add, label: "Add")
                IconExample(name: AppIcon.close, label: "Close")
                IconExample(name: AppIcon.back, label: "Back")
                IconExample(name: AppIcon.forward, label: "Forward")
                IconExample(name: AppIcon.expand, label: "Expand")
            }

            // Books
            IconSection(title: "Books") {
                IconExample(name: AppIcon.book, label: "Book")
                IconExample(name: AppIcon.bookFilled, label: "Book Filled")
                IconExample(name: AppIcon.bookCircle, label: "Book Circle")
                IconExample(name: AppIcon.bookPages, label: "Book Pages")
            }

            // Camera & Photos
            IconSection(title: "Camera & Photos") {
                IconExample(name: AppIcon.camera, label: "Camera")
                IconExample(name: AppIcon.photo, label: "Photo")
                IconExample(name: AppIcon.photos, label: "Photos")
            }

            // Status & Completion
            IconSection(title: "Status & Completion") {
                IconExample(name: AppIcon.checkmark, label: "Checkmark")
                IconExample(name: AppIcon.checkmarkFilled, label: "Checkmark Filled")
                IconExample(name: AppIcon.target, label: "Target")
                IconExample(name: AppIcon.trophy, label: "Trophy")
                IconExample(name: AppIcon.sparkles, label: "Sparkles")
            }

            // Progress & Time
            IconSection(title: "Progress & Time") {
                IconExample(name: AppIcon.timer, label: "Timer")
                IconExample(name: AppIcon.calendar, label: "Calendar")
                IconExample(name: AppIcon.speedometer, label: "Speedometer")
                IconExample(name: AppIcon.clock, label: "Clock")
            }

            // Timer Controls
            IconSection(title: "Timer Controls") {
                IconExample(name: AppIcon.play, label: "Play")
                IconExample(name: AppIcon.pause, label: "Pause")
                IconExample(name: AppIcon.stop, label: "Stop")
            }

            // Stats & Charts
            IconSection(title: "Stats & Charts") {
                IconExample(name: AppIcon.chartBar, label: "Chart Bar")
                IconExample(name: AppIcon.chartBarFilled, label: "Chart Bar Filled")
                IconExample(name: AppIcon.statistics, label: "Statistics")
            }

            // Actions
            IconSection(title: "Actions") {
                IconExample(name: AppIcon.edit, label: "Edit")
                IconExample(name: AppIcon.delete, label: "Delete")
                IconExample(name: AppIcon.addNote, label: "Add Note")
                IconExample(name: AppIcon.addCircle, label: "Add Circle")
            }
        }
        .padding()
    }
}

// Helper views for preview
import SwiftUI

private struct IconSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                content
            }
            Divider()
        }
    }
}

private struct IconExample: View {
    let name: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: name)
                .font(.title)
                .foregroundColor(.primaryDeep)
                .frame(height: 40)
            Text(label)
                .font(.caption2)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}
