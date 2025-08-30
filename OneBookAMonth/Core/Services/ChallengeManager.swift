//
//  ChallengeManager.swift
//  OneBookAMonth
//
//  Created by delightroom on 3/30/25.
//

import SwiftData
import SwiftUI

class ChallengeManager {
    private let modelContext: ModelContext
    private var calendar: Calendar {
        return Calendar.current
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Challenge Creation and Management
    
    /// Create a new challenge
    func createChallenge(name: String, targetPages: Int, startDate: Date, endDate: Date) throws -> Challenge {
        let challenge = Challenge(name: name, targetPages: targetPages, startDate: startDate, endDate: endDate)
        modelContext.insert(challenge)
        try saveContext()
        return challenge
    }
    
    /// Get the current active challenge
    func getActiveChallenge() -> Challenge? {
        let descriptor = FetchDescriptor<Challenge>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        
        do {
            let challenges = try modelContext.fetch(descriptor)
            return challenges.first(where: { $0.status == .active })
        } catch {
            print("Error fetching active challenge: \(error)")
            return nil
        }
    }
    
    /// Get all challenges
    func getAllChallenges() -> [Challenge] {
        let descriptor = FetchDescriptor<Challenge>(
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching challenges: \(error)")
            return []
        }
    }
    
    /// Update challenge status
    func updateChallengeStatus(_ challenge: Challenge, status: ChallengeStatus) {
        challenge.status = status
        if status == .completed && challenge.completedDate == nil {
            challenge.completedDate = Date()
        }
        do {
            try saveContext()
        } catch {
            print("Error updating challenge status: \(error)")
        }
    }
    
    /// Delete a challenge
    func deleteChallenge(_ challenge: Challenge) {
        modelContext.delete(challenge)
        do {
            try saveContext()
        } catch {
            print("Error deleting challenge: \(error)")
        }
    }
    
    // MARK: - Progress Tracking
    
    /// Calculate current progress for a challenge using ItemManager data
    func calculateChallengeProgress(_ challenge: Challenge, items: [Item]) -> ChallengeProgress {
        let startDate = challenge.startDate
        let endDate = challenge.endDate
        
        // Calculate total pages read within challenge period
        let totalPagesRead = items.reduce(0) { total, item in
            let itemPages = item.pageEntries
                .filter { entry in
                    entry.date >= startDate && entry.date <= endDate && entry.pagesRead > 0
                }
                .reduce(0) { $0 + $1.pagesRead }
            return total + itemPages
        }
        
        // Calculate progress percentage
        let progressPercentage = challenge.targetPages > 0 ? 
            min(Double(totalPagesRead) / Double(challenge.targetPages), 1.0) : 0.0
        
        // Calculate days information
        let today = Date()
        let daysElapsed = max(0, calendar.dateComponents([.day], from: startDate, to: min(today, endDate)).day ?? 0)
        let totalDays = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        let daysRemaining = max(0, calendar.dateComponents([.day], from: today, to: endDate).day ?? 0)
        
        // Calculate daily average needed to complete
        let pagesRemaining = max(0, challenge.targetPages - totalPagesRead)
        let dailyAverageNeeded = daysRemaining > 0 ? 
            Double(pagesRemaining) / Double(daysRemaining) : 0.0
        
        // Check for new milestones
        let newMilestones = checkForNewMilestones(challenge, currentPages: totalPagesRead)
        
        return ChallengeProgress(
            currentPages: totalPagesRead,
            targetPages: challenge.targetPages,
            progressPercentage: progressPercentage,
            daysElapsed: daysElapsed,
            daysRemaining: daysRemaining,
            totalDays: totalDays,
            dailyAverageNeeded: dailyAverageNeeded,
            newMilestones: newMilestones
        )
    }
    
    /// Check and award new milestones
    private func checkForNewMilestones(_ challenge: Challenge, currentPages: Int) -> [Int] {
        var newMilestones: [Int] = []
        
        for percentage in Challenge.milestonePercentages {
            if challenge.shouldAwardMilestone(percentage, currentPages: currentPages) {
                challenge.awardMilestone(percentage)
                newMilestones.append(percentage)
            }
        }
        
        if !newMilestones.isEmpty {
            do {
                try saveContext()
            } catch {
                print("Error saving milestones: \(error)")
            }
        }
        
        return newMilestones
    }
    
    /// Update challenge completion status
    func updateChallengeCompletion(_ challenge: Challenge, currentPages: Int) {
        challenge.checkCompletion(currentPages: currentPages)
        do {
            try saveContext()
        } catch {
            print("Error updating challenge completion: \(error)")
        }
    }
    
    // MARK: - Analytics
    
    /// Get challenge statistics
    func getChallengeStats(_ challenge: Challenge, items: [Item]) -> ChallengeStats {
        let progress = calculateChallengeProgress(challenge, items: items)
        let today = Date()
        
        // Calculate reading streak within challenge period
        var currentStreak = 0
        var currentDate = today
        
        while currentDate >= challenge.startDate {
            let dayPages = items.reduce(0) { total, item in
                total + item.getPagesReadForDate(currentDate)
            }
            
            if dayPages > 0 {
                currentStreak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        // Calculate best reading day
        var bestDay: (date: Date, pages: Int) = (Date(), 0)
        var currentCheckDate = challenge.startDate
        
        while currentCheckDate <= min(today, challenge.endDate) {
            let dayPages = items.reduce(0) { total, item in
                total + item.getPagesReadForDate(currentCheckDate)
            }
            
            if dayPages > bestDay.pages {
                bestDay = (currentCheckDate, dayPages)
            }
            
            currentCheckDate = calendar.date(byAdding: .day, value: 1, to: currentCheckDate) ?? challenge.endDate
        }
        
        return ChallengeStats(
            currentStreak: currentStreak,
            bestReadingDay: bestDay.date,
            bestReadingDayPages: bestDay.pages,
            averageDailyPages: progress.daysElapsed > 0 ? 
                Double(progress.currentPages) / Double(progress.daysElapsed) : 0.0,
            daysWithReading: getDaysWithReading(challenge, items: items)
        )
    }
    
    /// Get number of days with reading activity
    private func getDaysWithReading(_ challenge: Challenge, items: [Item]) -> Int {
        var daysWithActivity: Set<Date> = []
        
        for item in items {
            for entry in item.pageEntries {
                if entry.date >= challenge.startDate && 
                   entry.date <= challenge.endDate && 
                   entry.pagesRead > 0 {
                    daysWithActivity.insert(calendar.startOfDay(for: entry.date))
                }
            }
        }
        
        return daysWithActivity.count
    }
    
    // MARK: - Helper Methods
    
    private func saveContext() throws {
        do {
            try modelContext.save()
        } catch {
            print("Error saving challenge context: \(error)")
            throw error
        }
    }
}

// MARK: - Data Structures

struct ChallengeProgress {
    let currentPages: Int
    let targetPages: Int
    let progressPercentage: Double
    let daysElapsed: Int
    let daysRemaining: Int
    let totalDays: Int
    let dailyAverageNeeded: Double
    let newMilestones: [Int]
    
    var isCompleted: Bool {
        progressPercentage >= 1.0
    }
    
    var pagesRemaining: Int {
        max(0, targetPages - currentPages)
    }
}

struct ChallengeStats {
    let currentStreak: Int
    let bestReadingDay: Date
    let bestReadingDayPages: Int
    let averageDailyPages: Double
    let daysWithReading: Int
}