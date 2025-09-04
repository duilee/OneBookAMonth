//
//  NotificationManager.swift
//  OneBookAMonth
//
//  Created by Claude on 2025-08-31.
//

import Foundation
import UserNotifications
import SwiftData

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    @Published var permissionStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        checkPermissionStatus()
    }
    
    // MARK: - Permission Management
    
    func checkPermissionStatus() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.permissionStatus = settings.authorizationStatus
            }
        }
    }
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                self.checkPermissionStatus()
            }
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    // MARK: - Challenge Notifications
    
    func scheduleChallengeNotifications(for challenge: Challenge, progress: ChallengeProgress, todayPages: Int = 0) async {
        // First, ensure we have permission
        if permissionStatus != .authorized {
            let granted = await requestPermission()
            if !granted { return }
        }
        
        // Cancel any existing notifications for this challenge
        await cancelChallengeNotifications(for: challenge)
        
        // Create notification content
        let content = createNotificationContent(for: challenge, progress: progress, todayPages: todayPages)
        
        // Create trigger for daily notification at specified time
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: challenge.notificationTime)
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "challenge-\(challenge.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        do {
            try await notificationCenter.add(request)
            print("Scheduled notification for challenge: \(challenge.name)")
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
    
    func cancelChallengeNotifications(for challenge: Challenge) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["challenge-\(challenge.id.uuidString)"])
        print("Cancelled notifications for challenge: \(challenge.name)")
    }
    
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    // MARK: - Content Creation
    
    private func createNotificationContent(for challenge: Challenge, progress: ChallengeProgress, todayPages: Int = 0) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Time to Read! 📚"
        
        // Dynamic subtitle based on progress
        if progress.progress < 0.5 {
            content.subtitle = "Don't give up on your \(challenge.name) challenge!"
        } else if progress.progress < 0.8 {
            content.subtitle = "Keep going with your \(challenge.name) challenge!"
        } else {
            content.subtitle = "You're almost there! Finish strong! 🎯"
        }
        
        // Dynamic body based on daily needs
        let pagesNeeded = progress.dailyPagesNeeded - todayPages
        if pagesNeeded > 0 {
            content.body = progress.currentStreak > 0 ? "You need \(pagesNeeded) pages today to stay on track. Current streak: \(progress.currentStreak) days 🔥" : "You need \(pagesNeeded) pages today to stay on track. Keep going! 💪"
        } else {
            content.body = "Great job today! You've read \(todayPages) pages. Keep your \(progress.currentStreak)-day streak alive! 🔥"
        }
        
        content.sound = .default
        //content.badge = NSNumber(value: 0)
        
        // Add category for action buttons (future enhancement)
        content.categoryIdentifier = "READING_REMINDER"
        
        // Add user info for deep linking
        content.userInfo = [
            "challengeId": challenge.id.uuidString,
            "targetPages": progress.dailyPagesNeeded
        ]
        
        return content
    }
    
    // MARK: - Dynamic Message Generation
    
    func getMotivationalMessage(for progress: ChallengeProgress) -> String {
        let progressPercentage = progress.progress
        let streak = progress.currentStreak
        let daysRemaining = progress.daysRemaining
        
        if progressPercentage < 0.3 {
            return "Every page counts! You can do this! 💪"
        } else if progressPercentage < 0.5 {
            if streak > 3 {
                return "Your \(streak)-day streak is impressive! Keep it going!"
            } else {
                return "Building momentum! Just \(progress.dailyPagesNeeded) pages today!"
            }
        } else if progressPercentage < 0.8 {
            if daysRemaining < 7 {
                return "Final week! You're so close to completing your challenge!"
            } else {
                return "Halfway there! You're doing amazing!"
            }
        } else {
            return "You're crushing this challenge! 🚀"
        }
    }
}

