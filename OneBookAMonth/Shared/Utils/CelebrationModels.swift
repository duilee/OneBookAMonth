//
//  CelebrationModels.swift
//  OneBookAMonth
//
//  Created by Assistant on 2025-09-06.
//

import Foundation

// MARK: - Celebration Context
struct CelebrationContext {
    let pagesRead: Int           // Pages added this session
    let totalPagesToday: Int     // All pages read today
    let bookProgress: Float      // 0.0 to 1.0
    let streakDays: Int          // Current reading streak
    let isNewStreak: Bool        // Just started/extended streak
    let challengeImpact: ChallengeImpact?
    let milestones: [Milestone]  // Any milestones hit
    
    // Helper to determine if celebration should be shown
    var shouldShow: Bool {
        return pagesRead > 0 || 
               !milestones.isEmpty || 
               (isNewStreak && streakDays >= 3) ||
               challengeImpact != nil
    }
}

// MARK: - Challenge Impact
struct ChallengeImpact {
    let challengeName: String
    let daysCompleted: Int
    let daysTotal: Int
    let weekProgress: [Bool]     // [true, true, false, false, false, false, false]
    let daysRemaining: Int
    let isOnTrack: Bool
    let justCompletedDay: Bool   // Did this update complete a challenge day?
}

// MARK: - Milestones
enum Milestone: Equatable {
    case firstReadOfDay
    case bookQuarter, bookHalf, bookThreeQuarters, bookFinished
    case personalBest(type: String) // "Most pages in a day"
    case streakMilestone(days: Int) // 3, 7, 14, 30, 100
    
    var displayText: String {
        switch self {
        case .firstReadOfDay:
            return "First read of the day!"
        case .bookQuarter:
            return "25% complete!"
        case .bookHalf:
            return "Halfway through!"
        case .bookThreeQuarters:
            return "75% complete!"
        case .bookFinished:
            return "Book completed!"
        case .personalBest(let type):
            return "\(type)!"
        case .streakMilestone(let days):
            return "\(days)-day streak!"
        }
    }
    
    var emoji: String {
        switch self {
        case .firstReadOfDay:
            return "🌅"
        case .bookQuarter:
            return "📈"
        case .bookHalf:
            return "🎯"
        case .bookThreeQuarters:
            return "🚀"
        case .bookFinished:
            return "🏆"
        case .personalBest:
            return "⭐"
        case .streakMilestone:
            return "🔥"
        }
    }
}

// MARK: - Progress Status (different from Challenge.ChallengeStatus)
enum ProgressStatus {
    case onTrack
    case behind
    case completed
    case atRisk
    
    var displayText: String {
        switch self {
        case .onTrack: return "On Track"
        case .behind: return "Behind"
        case .completed: return "Completed"
        case .atRisk: return "At Risk"
        }
    }
    
    var color: (red: Double, green: Double, blue: Double) {
        switch self {
        case .onTrack: return (0.0, 0.6, 0.0)      // Green
        case .behind: return (1.0, 0.6, 0.0)       // Orange
        case .completed: return (0.0, 0.8, 0.0)    // Bright green
        case .atRisk: return (0.8, 0.2, 0.2)       // Red
        }
    }
}