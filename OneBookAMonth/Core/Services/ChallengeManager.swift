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