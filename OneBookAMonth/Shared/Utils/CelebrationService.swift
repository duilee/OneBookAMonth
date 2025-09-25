//
//  CelebrationService.swift
//  OneBookAMonth
//
//  Created by Assistant on 2025-09-06.
//

import Foundation
import SwiftData

class CelebrationService {
    
    static func generateCelebration(
        item: Item,
        oldPages: Int,
        newPages: Int,
        challenges: [Challenge],
        itemManager: ItemManager
    ) -> CelebrationContext {
        
        let pagesAdded = newPages - oldPages
        let calendar = Calendar.current
        let today = Date()
        
        // Calculate total pages read today (including this update)
        let totalPagesToday = item.getPagesReadForDate(today) + pagesAdded
        
        // Calculate reading streak
        let (streakDays, isNewStreak) = calculateStreak(item: item)
        
        // Check milestones
        let milestones = checkMilestones(
            item: item, 
            oldPages: oldPages, 
            newPages: newPages, 
            totalPagesToday: totalPagesToday,
            streakDays: streakDays,
            isNewStreak: isNewStreak
        )
        
        // Calculate challenge impact
        let challengeImpact = calculateChallengeImpact(
            item: item, 
            challenges: challenges, 
            pagesAdded: pagesAdded,
            totalPagesToday: totalPagesToday
        )
        
        return CelebrationContext(
            pagesRead: pagesAdded,
            totalPagesToday: totalPagesToday,
            bookProgress: Float(newPages) / Float(item.numberOfPages),
            streakDays: streakDays,
            isNewStreak: isNewStreak,
            challengeImpact: challengeImpact,
            milestones: milestones
        )
    }
    
    // MARK: - Streak Calculation
    
    private static func calculateStreak(item: Item) -> (days: Int, isNew: Bool) {
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        var streakDays = 0
        var isNewStreak = false
        
        // Check if user read today
        let todayPages = item.getPagesReadForDate(currentDate)
        if todayPages > 0 {
            streakDays = 1
            isNewStreak = true
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        } else {
            // If no reading today, check if they read yesterday to continue streak
            let yesterdayPages = item.getPagesReadForDate(currentDate)
            if yesterdayPages == 0 {
                return (0, false) // No recent reading
            }
        }
        
        // Count consecutive reading days going backwards
        while true {
            let pagesRead = item.getPagesReadForDate(currentDate)
            if pagesRead > 0 {
                streakDays += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return (streakDays, isNewStreak)
    }
    
    // MARK: - Milestone Detection
    
    private static func checkMilestones(
        item: Item,
        oldPages: Int,
        newPages: Int,
        totalPagesToday: Int,
        streakDays: Int,
        isNewStreak: Bool
    ) -> [Milestone] {
        
        var milestones: [Milestone] = []
        
        // First read of day
        if totalPagesToday == newPages - oldPages && totalPagesToday > 0 {
            milestones.append(.firstReadOfDay)
        }
        
        // Book progress milestones
        let oldProgress = Float(oldPages) / Float(item.numberOfPages)
        let newProgress = Float(newPages) / Float(item.numberOfPages)
        
        if oldProgress < 0.25 && newProgress >= 0.25 {
            milestones.append(.bookQuarter)
        }
        if oldProgress < 0.5 && newProgress >= 0.5 {
            milestones.append(.bookHalf)
        }
        if oldProgress < 0.75 && newProgress >= 0.75 {
            milestones.append(.bookThreeQuarters)
        }
        if oldProgress < 1.0 && newProgress >= 1.0 {
            milestones.append(.bookFinished)
        }
        
        // Streak milestones
        if isNewStreak {
            let significantStreaks = [3, 7, 14, 30, 100]
            if significantStreaks.contains(streakDays) {
                milestones.append(.streakMilestone(days: streakDays))
            }
        }
        
        // Personal best (simplified - could be enhanced with historical data)
        if totalPagesToday > 50 { // Arbitrary threshold for "big reading day"
            milestones.append(.personalBest(type: "Big reading day"))
        }
        
        return milestones
    }
    
    // MARK: - Challenge Impact
    
    private static func calculateChallengeImpact(
        item: Item,
        challenges: [Challenge],
        pagesAdded: Int,
        totalPagesToday: Int
    ) -> ChallengeImpact? {
        
        // Find active challenge
        guard let activeChallenge = challenges.first(where: { $0.isActive }) else {
            return nil
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Calculate days with reading during challenge
        var daysWithReading = 0
        var currentDate = activeChallenge.startDate
        print(currentDate)
        print(today)
        
        while currentDate <= min(today, activeChallenge.endDate) {
            print(currentDate)
            if item.getPagesReadForDate(currentDate) > 0 {
                daysWithReading += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Calculate this week's progress
        let weekProgress = calculateWeekProgress(item: item, challenge: activeChallenge)
        
        // Did this update complete a challenge day?
        let justCompletedDay = totalPagesToday == pagesAdded && pagesAdded > 0
        
        // Is user on track? (rough estimation - aim for ~70% of days)
        let targetDaysRatio = 0.7
        let expectedDays = Int(Double(activeChallenge.daysElapsed) * targetDaysRatio)
        let isOnTrack = daysWithReading >= expectedDays
        
        return ChallengeImpact(
            challengeName: activeChallenge.name,
            daysCompleted: daysWithReading,
            daysTotal: activeChallenge.duration,
            weekProgress: weekProgress,
            daysRemaining: activeChallenge.daysRemaining,
            isOnTrack: isOnTrack,
            justCompletedDay: justCompletedDay
        )
    }
    
    // MARK: - Week Progress Calculation
    
    private static func calculateWeekProgress(item: Item, challenge: Challenge) -> [Bool] {
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
            
            // Only check days within challenge period
            if day >= challenge.startDate && day <= min(today, challenge.endDate) {
                let pagesRead = item.getPagesReadForDate(day)
                weekProgress.append(pagesRead > 0)
            } else {
                weekProgress.append(false)
            }
        }
        
        return weekProgress
    }
}
