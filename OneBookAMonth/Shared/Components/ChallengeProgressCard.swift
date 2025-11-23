//
//  ChallengeProgressCard.swift
//  OneBookAMonth
//
//  Created by Assistant on 2025-09-06.
//

import SwiftUI
import SwiftData

struct ChallengeProgressCard: View {
    let item: Item
    let challenge: Challenge
    let itemManager: ItemManager
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            // Header with challenge name and status
            headerSection

            // Progress information
            progressSection

            // Weekly progress dots
            weeklyProgressSection

            // Motivational message
            motivationalSection
        }
        .cardStyle()
    }
    
    private var headerSection: some View {
        HStack {
            HStack(spacing: Spacing.xs) {
                Text(AppIcon.trophy)
                    .font(.headingLarge)

                Text(challenge.name)
                    .font(.challengeTitle)
                    .foregroundColor(.primaryDeep)
            }

            Spacer()

            challengeStatusBadge
        }
    }
    
    private var challengeStatusBadge: some View {
        let status = getChallengeStatus()

        return Text(status.text)
            .badgeStyle(color: status.color)
    }
    
    private var progressSection: some View {
        let daysWithReading = getDaysWithReading()
        let progress = Double(daysWithReading) / Double(challenge.duration)

        return VStack(alignment: .leading, spacing: Spacing.xs) {
            // Progress text
            HStack {
                Text("\(daysWithReading)/\(challenge.duration) days with reading")
                    .font(.labelMedium)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("\(challenge.daysRemaining) days left")
                    .font(.labelSmall)
                    .foregroundColor(.textSecondary)
            }

            // Progress bar
            progressBar(progress: progress)
        }
    }
    
    private func progressBar(progress: Double) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: CornerRadius.tiny)
                    .fill(Color.borderColor)
                    .frame(height: 8)

                // Progress track
                RoundedRectangle(cornerRadius: CornerRadius.tiny)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.primaryDeep,
                                Color.primaryDeep.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(geometry.size.width * progress, 0), height: 8)
            }
        }
        .frame(height: 8)
    }
    
    private var weeklyProgressSection: some View {
        VStack(spacing: Spacing.xs) {
            HStack {
                Text("This week:")
                    .font(.labelMedium)
                    .foregroundColor(.textPrimary)

                Spacer()

                weeklyProgressDots
            }
        }
    }
    
    private var weeklyProgressDots: some View {
        HStack(spacing: 6) {
            let weekProgress = getThisWeekProgress()
            let dayLabels = getDayLabels()

            ForEach(0..<7, id: \.self) { dayIndex in
                VStack(spacing: 2) {
                    // Day letter
                    Text(dayLabels[dayIndex])
                        .font(.labelTiny)
                        .foregroundColor(.textSecondary)

                    // Progress dot
                    Circle()
                        .fill(weekProgress[dayIndex] ?
                              Color.primaryDeep :
                              Color.borderColor)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(
                                    dayIndex == getCurrentDayOfWeek() ?
                                    Color.primaryDeep :
                                    Color.clear,
                                    lineWidth: 2
                                )
                                .frame(width: 16, height: 16)
                        )
                }
            }
        }
    }
    
    private var motivationalSection: some View {
        let message = getMotivationalMessage()

        return HStack(spacing: Spacing.xs) {
            Text(message.emoji)
                .font(.labelMedium)

            Text(message.text)
                .font(.labelSmall)
                .foregroundColor(message.color)

            Spacer()
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.small)
                .fill(message.backgroundColor.opacity(0.1))
        )
    }
    
    // MARK: - Helper Methods
    
    private func getDayLabels() -> [String] {
        let calendar = Calendar.current
        let firstWeekday = calendar.firstWeekday // 1 = Sunday, 2 = Monday, etc.
        let formatter = DateFormatter()
        formatter.locale = calendar.locale
        
        var labels: [String] = []
        for i in 0..<7 {
            // Calculate weekday index (1-7) starting from firstWeekday
            let weekdayIndex = ((firstWeekday - 1 + i) % 7) + 1
            let dayName = formatter.shortWeekdaySymbols[weekdayIndex - 1] // shortWeekdaySymbols is 0-indexed
            labels.append(String(dayName.prefix(1)).uppercased())
        }
        return labels
    }
    
    private func getChallengeStatus() -> (text: String, color: Color) {
        let daysWithReading = getDaysWithReading()
        let expectedDays = Int(Double(challenge.daysElapsed) * 0.7) // Aim for 70% of days

        if challenge.daysRemaining <= 0 {
            return ("Completed", .statusCompleted)
        } else if daysWithReading >= expectedDays {
            return ("On Track", .statusActive)
        } else {
            let daysBehind = expectedDays - daysWithReading
            if daysBehind >= 3 {
                return ("At Risk", .statusFailed)
            } else {
                return ("Behind", .statusPending)
            }
        }
    }
    
    private func getDaysWithReading() -> Int {
        let calendar = Calendar.current
        var count = 0
        var currentDate = challenge.startDate
        let endDate = min(Date(), challenge.endDate)
        
        while currentDate <= endDate {
            if item.getPagesReadForDate(currentDate) > 0 {
                count += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return count
    }
    
    private func getThisWeekProgress() -> [Bool] {
        let calendar = Calendar.current
        let today = Date()
        
        // Get start of current week (Sunday)
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return Array(repeating: false, count: 7)
        }
        
        var weekProgress: [Bool] = []
        
        // Check each day of current week
        for i in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: i, to: weekStart) else {
                weekProgress.append(false)
                continue
            }
            
            // Only check days within challenge period and up to today
            if day >= challenge.startDate && day <= min(today, challenge.endDate) {
                let pagesRead = item.getPagesReadForDate(day)
                weekProgress.append(pagesRead > 0)
            } else {
                weekProgress.append(false)
            }
        }
        
        return weekProgress
    }
    
    private func getCurrentDayOfWeek() -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date()) // 1-7, Sunday = 1
        let firstWeekday = calendar.firstWeekday // 1-7, Sunday = 1
        
        // Convert to 0-based index relative to first day of week
        return (weekday - firstWeekday + 7) % 7
    }
    
    private func getMotivationalMessage() -> (text: String, color: Color, emoji: String, backgroundColor: Color) {
        let daysSinceLastRead = getDaysSinceLastRead()
        let daysWithReading = getDaysWithReading()
        let expectedDays = Int(Double(challenge.daysElapsed) * 0.7)

        // Just read today
        if daysSinceLastRead == 0 {
            if item.getPagesReadForDate(Date()) > 0 {
                return ("Great work today!", .successGreen, "🌟", .successGreen)
            }
        }

        // Behind on challenge
        if daysWithReading < expectedDays {
            let daysBehind = expectedDays - daysWithReading
            if daysBehind >= 3 {
                return ("Challenge at risk! Time to catch up", .errorRed, "⚠️", .errorRed)
            } else {
                return ("A bit behind - you can do this!", .warningOrange, "💪", .warningOrange)
            }
        }

        // Haven't read recently
        if daysSinceLastRead >= 2 {
            return ("Haven't read in \(daysSinceLastRead) days", .warningOrange, "📚", .warningOrange)
        }

        // On track
        return ("You're doing great!", .primaryDeep, "🎯", .primaryDeep)
    }
    
    private func getDaysSinceLastRead() -> Int {
        let calendar = Calendar.current
        let sortedEntries = item.pageEntries.sorted { $0.date > $1.date }
        
        guard let lastReadDate = sortedEntries.first(where: { $0.pagesRead > 0 })?.date else {
            return 999
        }
        
        return calendar.dateComponents([.day], from: lastReadDate, to: Date()).day ?? 0
    }
}

// MARK: - Preview

//#Preview {
//    let calendar = Calendar.current
//    let startDate = calendar.date(byAdding: .day, value: -10, to: Date()) ?? Date()
//    let endDate = calendar.date(byAdding: .day, value: 20, to: Date()) ?? Date()
//    
//    let challenge = Challenge(
//        name: "January Reading Challenge",
//        startDate: startDate,
//        endDate: endDate,
//        targetPages: 500
//    )
//    
//    let item = Item(timestamp: Date(), name: "Sample Book", numberOfPages: 300)
//    
//    ChallengeProgressCard(
//        item: item,
//        challenge: challenge,
//        itemManager: nil // Preview doesn't need real manager
//    )
//    .padding()
//}