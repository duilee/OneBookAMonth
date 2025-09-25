//
//  ChallengeManager.swift
//  OneBookAMonth
//
//  Created by Claude on 2025-08-31.
//

import Foundation
import SwiftData
import SwiftUI

class ChallengeManager: ObservableObject {
    private let modelContext: ModelContext
    private let itemManager: ItemManager
    
    @Published var activeChallenge: Challenge?
    @Published var challenges: [Challenge] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.itemManager = ItemManager(modelContext: modelContext)
        loadChallenges()
    }
    
    // MARK: - Challenge CRUD Operations
    
    func createChallenge(name: String, startDate: Date, endDate: Date, targetPages: Int) -> Challenge {
        let challenge = Challenge(
            name: name,
            startDate: startDate,
            endDate: endDate,
            targetPages: targetPages
        )
        
        // Store initial pages read to track progress from this point
        let items = fetchAllItems()
        challenge.pagesReadAtStart = itemManager.getTotalPagesReadInDateRange(
            for: items,
            startDate: Date.distantPast,
            endDate: startDate
        )
        
        modelContext.insert(challenge)
        saveContext()
        loadChallenges()
        
        return challenge
    }
    
    func deleteChallenge(_ challenge: Challenge) {
        modelContext.delete(challenge)
        saveContext()
        loadChallenges()
    }
    
    func cancelChallenge(_ challenge: Challenge) {
        challenge.cancel()
        saveContext()
        loadChallenges()
    }
    
    // MARK: - Progress Calculation
    
    func calculateProgress(for challenge: Challenge) -> ChallengeProgress {
        let items = fetchAllItems()
        
        // Get total pages read during challenge period
        let pagesRead = itemManager.getTotalPagesReadInDateRange(
            for: items,
            startDate: challenge.startDate,
            endDate: min(Date(), challenge.endDate)
        )
        
        // Calculate daily average
        let readingDays = itemManager.getReadingDaysInRange(
            for: items,
            startDate: challenge.startDate,
            endDate: min(Date(), challenge.endDate)
        )
        
        let averagePagesPerDay = readingDays.count > 0 ? 
            Double(pagesRead) / Double(readingDays.count) : 0
        
        // Calculate pages needed per day
        let daysRemaining = challenge.daysRemaining
        let pagesRemaining = max(0, challenge.targetPages - pagesRead)
        let dailyPagesNeeded = daysRemaining > 0 ? 
            Int(ceil(Double(pagesRemaining) / Double(daysRemaining))) : 0
        
        // Calculate streak
        let currentStreak = itemManager.getReadingStreakInRange(
            for: items,
            startDate: challenge.startDate,
            endDate: challenge.endDate
        )
        
        return ChallengeProgress(
            pagesRead: pagesRead,
            targetPages: challenge.targetPages,
            progress: min(1.0, Double(pagesRead) / Double(challenge.targetPages)),
            daysElapsed: challenge.daysElapsed,
            daysRemaining: daysRemaining,
            averagePagesPerDay: averagePagesPerDay,
            dailyPagesNeeded: dailyPagesNeeded,
            currentStreak: currentStreak,
            readingDays: readingDays.count
        )
    }
    
    // MARK: - Daily Progress
    
    func getDailyProgress(for challenge: Challenge) -> [Date: Int] {
        let items = fetchAllItems()
        return itemManager.getDailyReadingData(
            for: items,
            startDate: challenge.startDate,
            endDate: challenge.endDate
        )
    }
    
    func getTodayPages(for challenge: Challenge) -> Int {
        let items = fetchAllItems()
        let todayData = itemManager.getDailyReadingData(
            for: items,
            startDate: Calendar.current.startOfDay(for: Date()),
            endDate: Date()
        )
        return todayData.values.reduce(0, +)
    }
    
    // MARK: - Status Management
    
    func checkAndUpdateAllChallenges() {
        let items = fetchAllItems()
        
        for challenge in challenges where challenge.status == .active {
            let progress = calculateProgress(for: challenge)
            
            if progress.pagesRead >= challenge.targetPages {
                challenge.complete()
            } else if challenge.isOverdue {
                challenge.fail()
            }
        }
        
        saveContext()
        loadChallenges()
    }
    
    func getActiveChallenge() -> Challenge? {
        return challenges.first { $0.isActive }
    }
    
    func getPendingChallenges() -> [Challenge] {
        return challenges.filter { $0.isPending }
    }
    
    func getCompletedChallenges() -> [Challenge] {
        return challenges.filter { $0.status == .completed }
    }
    
    func getFailedChallenges() -> [Challenge] {
        return challenges.filter { $0.status == .failed }
    }
    
    // MARK: - Chart Data
    
    func getChartData(for challenge: Challenge) -> [DailyChartData] {
        let dailyData = getDailyProgress(for: challenge)
        let calendar = Calendar.current
        var chartData: [DailyChartData] = []
        
        var currentDate = challenge.startDate
        let endDate = min(Date(), challenge.endDate)
        var cumulativePages = 0
        
        while currentDate <= endDate {
            let dayStart = calendar.startOfDay(for: currentDate)
            let dayPages = dailyData[dayStart] ?? 0
            cumulativePages += dayPages
            
            chartData.append(DailyChartData(
                date: currentDate,
                pagesRead: dayPages,
                cumulativePages: cumulativePages
            ))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate
        }
        
        return chartData
    }
    
    // MARK: - Analytics
    
    func getChallengeStats() -> ChallengeStats {
        let completed = getCompletedChallenges().count
        let failed = getFailedChallenges().count
        let total = challenges.count
        
        let successRate = total > 0 ? Double(completed) / Double(total) : 0
        
        let totalPagesRead = getCompletedChallenges().reduce(0) { sum, challenge in
            let progress = calculateProgress(for: challenge)
            return sum + progress.pagesRead
        }
        
        let averageDuration = challenges.isEmpty ? 0 : 
            challenges.reduce(0) { $0 + $1.duration } / challenges.count
        
        return ChallengeStats(
            totalChallenges: total,
            completedChallenges: completed,
            failedChallenges: failed,
            successRate: successRate,
            totalPagesRead: totalPagesRead,
            averageDuration: averageDuration
        )
    }
    
    // MARK: - Private Methods
    
    private func loadChallenges() {
        do {
            let descriptor = FetchDescriptor<Challenge>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            challenges = try modelContext.fetch(descriptor)
            activeChallenge = getActiveChallenge()
        } catch {
            print("Error loading challenges: \(error)")
            challenges = []
        }
    }
    
    private func fetchAllItems() -> [Item] {
        do {
            let descriptor = FetchDescriptor<Item>()
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching items: \(error)")
            return []
        }
    }
    
    func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

// MARK: - Challenge Progress Extensions
extension ChallengeManager {
    
    // Get active challenge for specific item (if any)
    func getActiveChallengeForItem(_ item: Item) -> Challenge? {
        // For now, return any active challenge since challenges apply to all reading
        // In the future, could be enhanced to support item-specific challenges
        return getActiveChallenge()
    }
    
    // Check if user is on track with a challenge
    func isOnTrack(_ challenge: Challenge, item: Item) -> Bool {
        let daysWithReading = getDaysWithReading(challenge: challenge, item: item)
        let expectedDays = Int(Double(challenge.daysElapsed) * 0.7) // Aim for 70% of days
        return daysWithReading >= expectedDays
    }
    
    // Get number of days with reading activity during challenge
    func getDaysWithReading(challenge: Challenge, item: Item) -> Int {
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
    
    // Get this week's progress for a specific item and challenge
    func getThisWeekProgress(_ challenge: Challenge, item: Item) -> [Bool] {
        let calendar = Calendar.current
        let today = Date()
        
        // Get start of current week (Sunday)
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return Array(repeating: false, count: 7)
        }
        
        var progress: [Bool] = []
        
        for i in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: i, to: weekStart) else {
                progress.append(false)
                continue
            }
            
            // Only check days within challenge period and up to today
            if day >= challenge.startDate && day <= min(today, challenge.endDate) {
                let hasProgress = item.getPagesReadForDate(day) > 0
                progress.append(hasProgress)
            } else {
                progress.append(false)
            }
        }
        
        return progress
    }
    
    // Get days since last reading for an item
    func daysSinceLastRead(_ item: Item) -> Int {
        let calendar = Calendar.current
        let sortedEntries = item.pageEntries.sorted { $0.date > $1.date }
        
        guard let lastReadDate = sortedEntries.first(where: { $0.pagesRead > 0 })?.date else {
            return 999 // No reading found
        }
        
        return calendar.dateComponents([.day], from: lastReadDate, to: Date()).day ?? 0
    }
    
    // Get challenge status for display
    func getProgressStatus(_ challenge: Challenge, item: Item) -> ProgressStatus {
        let daysWithReading = getDaysWithReading(challenge: challenge, item: item)
        let expectedDays = Int(Double(challenge.daysElapsed) * 0.7)
        
        if challenge.status == .completed {
            return .completed
        } else if challenge.daysRemaining <= 0 {
            return challenge.status == .active ? .completed : .completed
        } else if daysWithReading >= expectedDays {
            return .onTrack
        } else {
            let daysBehind = expectedDays - daysWithReading
            return daysBehind >= 3 ? .atRisk : .behind
        }
    }
    
    // Get all challenges (for celebration service)
    func getAllChallenges() -> [Challenge] {
        return challenges
    }
}

// MARK: - Supporting Types

struct ChallengeProgress {
    let pagesRead: Int
    let targetPages: Int
    let progress: Double
    let daysElapsed: Int
    let daysRemaining: Int
    let averagePagesPerDay: Double
    let dailyPagesNeeded: Int
    let currentStreak: Int
    let readingDays: Int
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    var isOnTrack: Bool {
        averagePagesPerDay >= Double(dailyPagesNeeded)
    }
    
    var pagesRemaining: Int {
        max(0, targetPages - pagesRead)
    }
}

struct DailyChartData: Identifiable {
    let id = UUID()
    let date: Date
    let pagesRead: Int
    let cumulativePages: Int
}

struct ChallengeStats {
    let totalChallenges: Int
    let completedChallenges: Int
    let failedChallenges: Int
    let successRate: Double
    let totalPagesRead: Int
    let averageDuration: Int
}