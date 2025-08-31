//
//  ChallengeViewModel.swift
//  OneBookAMonth
//
//  Created by Claude on 2025-08-31.
//

import SwiftUI
import SwiftData

@Observable
class ChallengeViewModel {
    private var challengeManager: ChallengeManager?
    private var notificationManager = NotificationManager.shared
    var activeChallenge: Challenge?
    var challengeProgress: ChallengeProgress?
    var todayPages: Int = 0
    var showCreateChallenge: Bool = false
    var errorMessage: String?
    
    // Notification settings
    var notificationsEnabled: Bool = false
    var notificationTime: Date = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date()
    
    init() {}
    
    func setup(with modelContext: ModelContext) {
        if challengeManager == nil {
            challengeManager = ChallengeManager(modelContext: modelContext)
            refreshData()
        }
    }
    
    func refreshData() {
        guard let manager = challengeManager else { return }
        
        // Check and update challenge statuses
        manager.checkAndUpdateAllChallenges()
        
        // Get active challenge
        activeChallenge = manager.getActiveChallenge()
        
        // Calculate progress if there's an active challenge
        if let challenge = activeChallenge {
            challengeProgress = manager.calculateProgress(for: challenge)
            todayPages = manager.getTodayPages(for: challenge)
            
            // Load notification settings from challenge
            notificationsEnabled = challenge.notificationsEnabled
            notificationTime = challenge.notificationTime
        } else {
            challengeProgress = nil
            todayPages = 0
            notificationsEnabled = false
        }
    }
    
    func createChallenge(name: String, startDate: Date, endDate: Date, targetPages: Int) -> Bool {
        guard let manager = challengeManager else { 
            errorMessage = "Challenge manager not initialized"
            return false
        }
        
        // Check if there's already an active challenge
        if manager.getActiveChallenge() != nil {
            errorMessage = "You already have an active challenge. Complete or cancel it before creating a new one."
            return false
        }
        
        // Validate dates
        if endDate <= startDate {
            errorMessage = "End date must be after start date"
            return false
        }
        
        // Validate target pages
        if targetPages <= 0 {
            errorMessage = "Target pages must be greater than 0"
            return false
        }
        
        // Create the challenge
        _ = manager.createChallenge(
            name: name,
            startDate: startDate,
            endDate: endDate,
            targetPages: targetPages
        )
        
        refreshData()
        return true
    }
    
    func cancelChallenge() {
        guard let manager = challengeManager,
              let challenge = activeChallenge else { return }
        
        // Cancel notifications when cancelling challenge
        Task {
            await notificationManager.cancelChallengeNotifications(for: challenge)
        }
        
        manager.cancelChallenge(challenge)
        refreshData()
    }
    
    func getStatusColor() -> Color {
        guard let progress = challengeProgress else { return .gray }
        
        if progress.isOnTrack {
            return .green
        } else if progress.daysRemaining > 3 {
            return .orange
        } else {
            return .red
        }
    }
    
    func getStatusText() -> String {
        guard let progress = challengeProgress else { return "" }
        
        if progress.progress >= 1.0 {
            return "Completed!"
        } else if progress.isOnTrack {
            return "On Track"
        } else if progress.daysRemaining > 0 {
            return "Behind Schedule"
        } else {
            return "Challenge Failed"
        }
    }
    
    func getMotivationalMessage() -> String {
        guard let progress = challengeProgress else {
            return "Start a new reading challenge!"
        }
        
        if progress.progress >= 1.0 {
            return "Congratulations! You've completed your challenge!"
        } else if progress.isOnTrack {
            if progress.currentStreak >= 7 {
                return "Amazing \(progress.currentStreak)-day streak! Keep it up!"
            } else if progress.currentStreak >= 3 {
                return "\(progress.currentStreak) days in a row! You're building a habit!"
            } else {
                return "You're doing great! Keep reading!"
            }
        } else if progress.daysRemaining > 0 {
            return "You need \(progress.dailyPagesNeeded) pages per day to finish on time"
        } else {
            return "Don't give up! Start a new challenge and try again"
        }
    }
    
    // MARK: - Notification Methods
    
    func updateNotificationSettings() {
        guard let challenge = activeChallenge,
              let progress = challengeProgress else { return }
        
        // Update challenge model
        challenge.notificationsEnabled = notificationsEnabled
        challenge.notificationTime = notificationTime
        
        // Save changes
        challengeManager?.saveContext()
        
        // Update notification scheduling
        Task {
            if notificationsEnabled {
                await notificationManager.scheduleChallengeNotifications(for: challenge, progress: progress, todayPages: todayPages)
            } else {
                await notificationManager.cancelChallengeNotifications(for: challenge)
            }
        }
    }
    
    func getNotificationPreviewMessage() -> String {
        guard let progress = challengeProgress else {
            return "Time to read! 📚"
        }
        
        let pagesNeeded = progress.dailyPagesNeeded - todayPages
        if pagesNeeded > 0 {
            return "You need \(pagesNeeded) pages today to stay on track"
        } else {
            return "Great job! You've read \(todayPages) pages today"
        }
    }
}