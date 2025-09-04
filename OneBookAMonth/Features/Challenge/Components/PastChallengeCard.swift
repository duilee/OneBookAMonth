//
//  PastChallengeCard.swift
//  OneBookAMonth
//
//  Created by Claude on 2025-09-02.
//

import SwiftUI
import SwiftData

struct PastChallengeCard: View {
    let challenge: Challenge
    let progress: ChallengeProgress
    let onDelete: (() -> Void)?
    @State private var showDetails = false
    
    private let primaryColor = Color(red: 25/255, green: 45/255, blue: 155/255)
    
    var body: some View {
        Button(action: { showDetails = true }) {
            HStack(spacing: 12) {
                // Completion Status Icon
                ZStack {
                    Circle()
                        .fill(statusBackgroundColor)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: statusIcon)
                        .font(.system(size: 20))
                        .foregroundColor(statusColor)
                }
                
                // Challenge Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatChallengeDate())
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Label("\(progress.pagesRead) pages", 
                              systemImage: "doc.text")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        if progress.readingDays > 0 {
                            Text("•")
                                .foregroundColor(.secondary.opacity(0.5))
                            
                            Label("\(progress.readingDays) days", 
                                  systemImage: "calendar")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Achievement Badge
                if challenge.status == .completed && progress.progress >= 1.0 {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.yellow)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.03), 
                           radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetails) {
            PastChallengeDetailView(challenge: challenge, progress: progress, onDelete: onDelete)
        }
    }
    
    private var statusIcon: String {
        switch challenge.status {
        case .completed:
            return "checkmark.circle.fill"
        case .failed:
            return "xmark.circle"
        case .cancelled:
            return "minus.circle"
        case .active:
            return "circle.dotted"
        }
    }
    
    private var statusColor: Color {
        switch challenge.status {
        case .completed:
            return .green
        case .failed:
            return .red
        case .cancelled:
            return .orange
        case .active:
            return .blue
        }
    }
    
    private var statusBackgroundColor: Color {
        switch challenge.status {
        case .completed:
            return Color.green.opacity(0.1)
        case .failed:
            return Color.red.opacity(0.1)
        case .cancelled:
            return Color.orange.opacity(0.1)
        case .active:
            return Color.blue.opacity(0.1)
        }
    }
    
    private func formatChallengeDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: challenge.startDate)
    }
}

// Enhanced card for when no active challenge exists
struct PastChallengeEnhancedCard: View {
    let challenge: Challenge
    let progress: ChallengeProgress
    let onDelete: (() -> Void)?
    @State private var showDetails = false
    
    private let primaryColor = Color(red: 25/255, green: 45/255, blue: 155/255)
    
    var body: some View {
        Button(action: { showDetails = true }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formatMonthYear())
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("\(challenge.duration) day challenge")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Status Badge
                    Text(statusText)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(statusColor.opacity(0.1))
                        )
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(progressBarColor)
                            .frame(width: geometry.size.width * min(1.0, progress.progress))
                    }
                }
                .frame(height: 8)
                
                // Stats Row
                HStack(spacing: 20) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 12))
                        Text("\(progress.pagesRead)")
                            .font(.system(size: 13, weight: .medium))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "target")
                            .font(.system(size: 12))
                        Text("\(Int(progress.progress * 100))%")
                            .font(.system(size: 13, weight: .medium))
                    }
                    
                    if progress.currentStreak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            Text("\(progress.currentStreak) days")
                                .font(.system(size: 13, weight: .medium))
                        }
                    }
                    
                    Spacer()
                }
                .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetails) {
            PastChallengeDetailView(challenge: challenge, progress: progress, onDelete: onDelete)
        }
    }
    
    private var statusText: String {
        switch challenge.status {
        case .completed:
            return "Completed"
        case .failed:
            return "Failed"
        case .cancelled:
            return "Cancelled"
        case .active:
            return "In Progress"
        }
    }
    
    private var statusColor: Color {
        switch challenge.status {
        case .completed:
            return .green
        case .failed:
            return .red
        case .cancelled:
            return .orange
        case .active:
            return .blue
        }
    }
    
    private var progressBarColor: Color {
        switch challenge.status {
        case .completed:
            return .green
        case .failed:
            return .red
        case .cancelled:
            return .orange
        case .active:
            return .blue
        }
    }
    
    private func formatMonthYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: challenge.startDate)
    }
}

// Detail view for past challenges
struct PastChallengeDetailView: View {
    let challenge: Challenge
    let progress: ChallengeProgress
    let onDelete: (() -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    
    private let primaryColor = Color(red: 25/255, green: 45/255, blue: 155/255)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Progress Ring
                    ChallengeProgressRing(
                        progress: progress.progress,
                        pagesRead: progress.pagesRead,
                        targetPages: progress.targetPages,
                        size: 180
                    )
                    .padding(.vertical, 20)
                    
                    // Challenge Info
                    VStack(spacing: 16) {
                        InfoRow(label: "Duration", value: formatDateRange())
                        InfoRow(label: "Status", value: statusText, valueColor: statusColor)
                        InfoRow(label: "Pages Read", value: "\(progress.pagesRead) of \(progress.targetPages)")
                        InfoRow(label: "Reading Days", value: "\(progress.readingDays) days")
                        InfoRow(label: "Average Daily", value: "\(Int(progress.averagePagesPerDay)) pages")
                        
                        if progress.currentStreak > 0 {
                            InfoRow(label: "Best Streak", value: "\(progress.currentStreak) days")
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .navigationTitle(challenge.name.isEmpty ? "Challenge Details" : challenge.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if canDeleteChallenge && onDelete != nil {
                        Menu {
                            Button(role: .destructive) {
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete Challenge", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(primaryColor)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(primaryColor)
                }
            }
            .confirmationDialog(
                "Delete Challenge?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    onDelete?()
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete this challenge record. This action cannot be undone.")
            }
        }
    }
    
    private var statusText: String {
        switch challenge.status {
        case .completed:
            return "Completed"
        case .failed:
            return "Failed"
        case .cancelled:
            return "Cancelled"
        case .active:
            return "In Progress"
        }
    }
    
    private var statusColor: Color {
        switch challenge.status {
        case .completed:
            return .green
        case .failed:
            return .red
        case .cancelled:
            return .orange
        case .active:
            return .blue
        }
    }
    
    private func formatDateRange() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: challenge.startDate)
        let end = formatter.string(from: challenge.endDate)
        return "\(start) - \(end)"
    }
    
    private var canDeleteChallenge: Bool {
        // Don't allow deletion of active challenges
        challenge.status != .active
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(valueColor)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// Summary stat item for no active challenge view
struct StatSummaryItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}