//
//  ChallengeCard.swift
//  OneBookAMonth
//
//  Created by Claude on 2025-08-31.
//

import SwiftUI

struct ChallengeCard: View {
    let challenge: Challenge
    let progress: ChallengeProgress
    let isCompact: Bool
    
    private let primaryColor = Color(red: 25/255, green: 45/255, blue: 155/255)
    
    init(challenge: Challenge, progress: ChallengeProgress, isCompact: Bool = false) {
        self.challenge = challenge
        self.progress = progress
        self.isCompact = isCompact
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 12 : 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.name)
                        .font(.system(size: isCompact ? 18 : 20, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        // Status Badge
                        StatusBadge(isOnTrack: progress.isOnTrack)
                        
                        // Days remaining
                        if challenge.daysRemaining > 0 {
                            Text("\(challenge.daysRemaining) days left")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if !isCompact {
                    MiniProgressRing(progress: progress.progress, size: 50)
                }
            }
            
            if !isCompact {
                Divider()
                
                // Stats Grid
                HStack(spacing: 20) {
                    StatItem(
                        icon: "book.pages",
                        value: "\(progress.pagesRead)",
                        label: "Pages Read",
                        color: primaryColor
                    )
                    
                    StatItem(
                        icon: "flame.fill",
                        value: "\(progress.currentStreak)",
                        label: "Day Streak",
                        color: .orange
                    )
                    
                    StatItem(
                        icon: "target",
                        value: "\(progress.dailyPagesNeeded)",
                        label: "Daily Goal",
                        color: progress.isOnTrack ? .green : .red
                    )
                }
                
                // Progress Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(progress.progressPercentage)%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(primaryColor)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(primaryColor)
                                .frame(width: geometry.size.width * progress.progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding(isCompact ? 12 : 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct StatusBadge: View {
    let isOnTrack: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isOnTrack ? Color.green : Color.orange)
                .frame(width: 6, height: 6)
            
            Text(isOnTrack ? "On Track" : "Behind")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isOnTrack ? .green : .orange)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill((isOnTrack ? Color.green : Color.orange).opacity(0.1))
        )
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Text(label)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: 20) {
        ChallengeCard(
            challenge: Challenge(
                name: "Summer Reading Challenge",
                startDate: Date(),
                endDate: Date().addingTimeInterval(30 * 24 * 60 * 60),
                targetPages: 500
            ),
            progress: ChallengeProgress(
                pagesRead: 234,
                targetPages: 500,
                progress: 0.468,
                daysElapsed: 10,
                daysRemaining: 20,
                averagePagesPerDay: 23.4,
                dailyPagesNeeded: 15,
                currentStreak: 5,
                readingDays: 8
            )
        )
        
        ChallengeCard(
            challenge: Challenge(
                name: "Quick Challenge",
                startDate: Date(),
                endDate: Date().addingTimeInterval(7 * 24 * 60 * 60),
                targetPages: 200
            ),
            progress: ChallengeProgress(
                pagesRead: 150,
                targetPages: 200,
                progress: 0.75,
                daysElapsed: 5,
                daysRemaining: 2,
                averagePagesPerDay: 30,
                dailyPagesNeeded: 25,
                currentStreak: 3,
                readingDays: 5
            ),
            isCompact: true
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}