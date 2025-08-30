//
//  ChallengeCard.swift
//  OneBookAMonth
//
//  Created by delightroom on 3/30/25.
//

import SwiftUI
import SwiftData

struct ChallengeCard: View {
    let challenge: Challenge
    let progress: ChallengeProgress
    let stats: ChallengeStats?
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with challenge name and status
            challengeHeader
            
            // Main progress display
            HStack(spacing: 24) {
                // Large progress ring
                LargeChallengeProgressRing(
                    progress: progress.progressPercentage,
                    currentPages: progress.currentPages,
                    targetPages: progress.targetPages,
                    daysRemaining: progress.daysRemaining
                )
                
                // Progress details
                VStack(alignment: .leading, spacing: 12) {
                    progressSummary
                    
                    if progress.daysRemaining > 0 && !progress.isCompleted {
                        dailyGoalInfo
                    }
                    
                    if let stats = stats, stats.currentStreak > 0 {
                        streakInfo
                    }
                }
                
                Spacer()
            }
            
            // Action buttons or completion message
            if progress.isCompleted {
                completionMessage
            } else if progress.daysRemaining == 0 && !progress.isCompleted {
                challengeFailedMessage
            } else {
                challengeActions
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
    }
    
    // MARK: - Component Views
    
    private var challengeHeader: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(formatDate(challenge.startDate)) - \(formatDate(challenge.endDate))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status badge
                statusBadge
            }
        }
    }
    
    private var statusBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: challenge.status.systemImage)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(challenge.status.color)
            
            Text(challenge.status.rawValue)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(challenge.status.color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(challenge.status.color.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var progressSummary: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 14))
                    .foregroundColor(ColorPalette().deep)
                
                Text("Progress")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Text("\(progress.currentPages) / \(progress.targetPages) pages")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("\(progress.pagesRemaining) pages remaining")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
    
    private var dailyGoalInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .font(.system(size: 14))
                    .foregroundColor(progress.dailyAverageNeeded > 50 ? .orange : ColorPalette().deep)
                
                Text("Daily Goal")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Text("\(Int(progress.dailyAverageNeeded.rounded())) pages/day")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(progress.dailyAverageNeeded > 50 ? .orange : ColorPalette().deep)
            
            Text("to complete on time")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
    
    private var streakInfo: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14))
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(stats?.currentStreak ?? 0) day streak")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.orange)
                
                Text("Keep it up!")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var completionMessage: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                
                Text("Challenge Completed!")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.green)
                
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
            }
            
            if let completedDate = challenge.completedDate {
                Text("Finished on \(formatDate(completedDate))")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            // Show completion stats
            if let stats = stats {
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("\(Int(stats.averageDailyPages.rounded()))")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.green)
                        
                        Text("avg pages/day")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(stats.daysWithReading)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.green)
                        
                        Text("reading days")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    if stats.bestReadingDayPages > 0 {
                        VStack(spacing: 4) {
                            Text("\(stats.bestReadingDayPages)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.green)
                            
                            Text("best day")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    private var challengeFailedMessage: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock.badge.xmark")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                
                Text("Challenge Ended")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.red)
            }
            
            Text("Time's up! You read \(progress.currentPages) out of \(progress.targetPages) pages.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("That's still \(Int(progress.progressPercentage * 100))% progress - great effort!")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ColorPalette().deep)
                .multilineTextAlignment(.center)
        }
    }
    
    private var challengeActions: some View {
        HStack(spacing: 12) {
            // Encourage button
            Button(action: {
                // Could show encouragement modal or tips
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16))
                    
                    Text("Keep Going!")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(ColorPalette().deep)
                .cornerRadius(12)
            }
            
            Spacer()
            
            // Days remaining info
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(progress.daysRemaining)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(progress.daysRemaining <= 7 ? .orange : ColorPalette().deep)
                
                Text("days left")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Compact Challenge Card

struct CompactChallengeCard: View {
    let challenge: Challenge
    let progress: ChallengeProgress
    
    var body: some View {
        HStack(spacing: 16) {
            // Progress ring
            ChallengeProgressRing(progress: progress.progressPercentage, size: 60)
            
            // Challenge info
            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("\(progress.currentPages) / \(progress.targetPages) pages")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                if progress.daysRemaining > 0 {
                    Text("\(progress.daysRemaining) days left")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(progress.daysRemaining <= 7 ? .orange : ColorPalette().medium)
                }
            }
            
            Spacer()
            
            // Status
            Image(systemName: challenge.status.systemImage)
                .font(.system(size: 16))
                .foregroundColor(challenge.status.color)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview("Active Challenge") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Challenge.self, Item.self, PageEntry.self, Memo.self, configurations: config)
    let context = container.mainContext
    
    // Create sample challenges in the ModelContainer context
    let activeChallenge = Challenge(
        name: "March Reading Challenge",
        targetPages: 1000,
        startDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date()
    )
    context.insert(activeChallenge)
    
    let compactChallenge = Challenge(
        name: "Quick Week Challenge",
        targetPages: 300,
        startDate: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date()
    )
    context.insert(compactChallenge)
    
    try? context.save()
    
    return VStack(spacing: 20) {
        ChallengeCard(
            challenge: activeChallenge,
            progress: ChallengeProgress(
                currentPages: 650,
                targetPages: 1000,
                progressPercentage: 0.65,
                daysElapsed: 15,
                daysRemaining: 15,
                totalDays: 30,
                dailyAverageNeeded: 23.3,
                newMilestones: []
            ),
            stats: ChallengeStats(
                currentStreak: 5,
                bestReadingDay: Date(),
                bestReadingDayPages: 45,
                averageDailyPages: 43.3,
                daysWithReading: 12
            )
        )
        
        CompactChallengeCard(
            challenge: compactChallenge,
            progress: ChallengeProgress(
                currentPages: 120,
                targetPages: 300,
                progressPercentage: 0.4,
                daysElapsed: 3,
                daysRemaining: 4,
                totalDays: 7,
                dailyAverageNeeded: 45.0,
                newMilestones: []
            )
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .modelContainer(container)
}

#Preview("Completed Challenge") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Challenge.self, Item.self, PageEntry.self, Memo.self, configurations: config)
    let context = container.mainContext
    
    let completedChallenge = Challenge(
        name: "February Reading Sprint",
        targetPages: 800,
        startDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
        endDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
    )
    completedChallenge.status = .completed
    completedChallenge.completedDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())
    context.insert(completedChallenge)
    
    try? context.save()
    
    return ChallengeCard(
        challenge: completedChallenge,
        progress: ChallengeProgress(
            currentPages: 850,
            targetPages: 800,
            progressPercentage: 1.0,
            daysElapsed: 28,
            daysRemaining: 0,
            totalDays: 28,
            dailyAverageNeeded: 0,
            newMilestones: []
        ),
        stats: ChallengeStats(
            currentStreak: 8,
            bestReadingDay: Date(),
            bestReadingDayPages: 62,
            averageDailyPages: 30.4,
            daysWithReading: 25
        )
    )
    .padding()
    .modelContainer(container)
}