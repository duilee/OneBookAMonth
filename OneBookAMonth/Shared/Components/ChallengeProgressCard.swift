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
    
    // MARK: - Spacing Constants (8pt Grid System)
    private let spacing = (
        xs: CGFloat(4),
        sm: CGFloat(8),
        md: CGFloat(16),
        lg: CGFloat(24)
    )
    
    var body: some View {
        VStack(spacing: spacing.md) {
            // Header with challenge name and status
            headerSection
            
            // Progress information
            progressSection
            
            // Weekly progress dots
            weeklyProgressSection
            
            // Motivational message
            motivationalSection
        }
        .padding(spacing.md)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    private var headerSection: some View {
        HStack {
            HStack(spacing: spacing.sm) {
                Text("🏆")
                    .font(.system(size: 20))
                
                Text(challenge.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
            }
            
            Spacer()
            
            challengeStatusBadge
        }
    }
    
    private var challengeStatusBadge: some View {
        let status = getChallengeStatus()
        
        return Text(status.text)
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, spacing.sm)
            .padding(.vertical, spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: status.color.red, green: status.color.green, blue: status.color.blue).opacity(0.15))
            )
            .foregroundColor(Color(red: status.color.red, green: status.color.green, blue: status.color.blue))
    }
    
    private var progressSection: some View {
        let daysWithReading = getDaysWithReading()
        let progress = Double(daysWithReading) / Double(challenge.duration)
        
        return VStack(alignment: .leading, spacing: spacing.sm) {
            // Progress text
            HStack {
                Text("\(daysWithReading)/\(challenge.duration) days with reading")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(challenge.daysRemaining) days left")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            progressBar(progress: progress)
        }
    }
    
    private func progressBar(progress: Double) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                // Progress track
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 25/255, green: 45/255, blue: 155/255),
                                Color(red: 25/255, green: 45/255, blue: 155/255).opacity(0.8)
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
        VStack(spacing: spacing.sm) {
            HStack {
                Text("This week:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
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
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    // Progress dot
                    Circle()
                        .fill(weekProgress[dayIndex] ? 
                              Color(red: 25/255, green: 45/255, blue: 155/255) : 
                              Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(
                                    dayIndex == getCurrentDayOfWeek() ? 
                                    Color(red: 25/255, green: 45/255, blue: 155/255) : 
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
        
        return HStack(spacing: spacing.sm) {
            Text(message.emoji)
                .font(.system(size: 14))
            
            Text(message.text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(message.color)
            
            Spacer()
        }
        .padding(.horizontal, spacing.sm)
        .padding(.vertical, spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 8)
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
    
    private func getChallengeStatus() -> (text: String, color: (red: Double, green: Double, blue: Double)) {
        let daysWithReading = getDaysWithReading()
        let expectedDays = Int(Double(challenge.daysElapsed) * 0.7) // Aim for 70% of days
        
        if challenge.daysRemaining <= 0 {
            return ("Completed", (red: 0.0, green: 0.6, blue: 0.0))
        } else if daysWithReading >= expectedDays {
            return ("On Track", (red: 25/255, green: 45/255, blue: 155/255))
        } else {
            let daysBehind = expectedDays - daysWithReading
            if daysBehind >= 3 {
                return ("At Risk", (red: 0.8, green: 0.2, blue: 0.2))
            } else {
                return ("Behind", (red: 1.0, green: 0.6, blue: 0.0))
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
                return ("Great work today!", .green, "🌟", .green)
            }
        }
        
        // Behind on challenge
        if daysWithReading < expectedDays {
            let daysBehind = expectedDays - daysWithReading
            if daysBehind >= 3 {
                return ("Challenge at risk! Time to catch up", .red, "⚠️", .red)
            } else {
                return ("A bit behind - you can do this!", .orange, "💪", .orange)
            }
        }
        
        // Haven't read recently
        if daysSinceLastRead >= 2 {
            return ("Haven't read in \(daysSinceLastRead) days", .orange, "📚", .orange)
        }
        
        // On track
        return ("You're doing great!", Color(red: 25/255, green: 45/255, blue: 155/255), "🎯", Color(red: 25/255, green: 45/255, blue: 155/255))
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