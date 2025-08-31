//
//  Challenge.swift
//  OneBookAMonth
//
//  Created by Claude on 2025-08-31.
//

import Foundation
import SwiftData

enum ChallengeStatus: String, Codable, CaseIterable {
    case active = "active"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
}

@Model
final class Challenge {
    var id: UUID
    var name: String
    var createdAt: Date
    var startDate: Date
    var endDate: Date
    var targetPages: Int
    var statusRawValue: String
    var completedAt: Date?
    var pagesReadAtStart: Int
    
    // Notification settings
    var notificationsEnabled: Bool = false
    var notificationTime: Date = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date()
    var lastNotificationSent: Date?
    
    var status: ChallengeStatus {
        get { ChallengeStatus(rawValue: statusRawValue) ?? .active }
        set { statusRawValue = newValue.rawValue }
    }
    
    // Computed properties
    var duration: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1
    }
    
    var daysElapsed: Int {
        let calendar = Calendar.current
        let now = Date()
        if now < startDate { return 0 }
        if now > endDate { return duration }
        let components = calendar.dateComponents([.day], from: startDate, to: now)
        return (components.day ?? 0) + 1
    }
    
    var daysRemaining: Int {
        max(0, duration - daysElapsed)
    }
    
    var isActive: Bool {
        let now = Date()
        return status == .active && now >= startDate && now <= endDate
    }
    
    var isOverdue: Bool {
        return Date() > endDate && status == .active
    }
    
    var isPending: Bool {
        return Date() < startDate && status == .active
    }
    
    init(
        name: String,
        startDate: Date,
        endDate: Date,
        targetPages: Int
    ) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.startDate = startDate
        self.endDate = endDate
        self.targetPages = targetPages
        self.statusRawValue = ChallengeStatus.active.rawValue
        self.completedAt = nil
        self.pagesReadAtStart = 0
    }
    
    // Methods
    func complete() {
        status = .completed
        completedAt = Date()
    }
    
    func fail() {
        status = .failed
        completedAt = Date()
    }
    
    func cancel() {
        status = .cancelled
        completedAt = Date()
    }
}
