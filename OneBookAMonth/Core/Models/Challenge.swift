//
//  Challenge.swift
//  OneBookAMonth
//
//  Created by delightroom on 3/30/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Challenge {
    var id: UUID = UUID()
    var name: String = ""
    var targetPages: Int = 0
    var startDate: Date = Date()
    var endDate: Date = Date()
    var status: ChallengeStatus = .active
    var createdDate: Date = Date()
    var completedDate: Date?
    var achievedMilestones: [String] = []
    
    // Computed properties for progress tracking
    var isActive: Bool {
        status == .active
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let now = Date()
        if now > endDate {
            return 0
        }
        return calendar.dateComponents([.day], from: now, to: endDate).day ?? 0
    }
    
    var totalDays: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    var progressPercentage: Double {
        return totalDays > 0 ? Double(totalDays - daysRemaining) / Double(totalDays) : 0.0
    }
    
    init(name: String, targetPages: Int, startDate: Date, endDate: Date) {
        self.name = name
        self.targetPages = targetPages
        self.startDate = startDate
        self.endDate = endDate
        self.status = .active
        self.createdDate = Date()
        self.completedDate = nil
    }
    
    // Helper method to check if milestone should be awarded
    func shouldAwardMilestone(_ percentage: Int, currentPages: Int) -> Bool {
        let milestoneString = "\(percentage)%"
        let milestoneThreshold = Double(percentage) / 100.0
        let currentProgress = Double(currentPages) / Double(targetPages)
        
        return currentProgress >= milestoneThreshold && !achievedMilestones.contains(milestoneString)
    }
    
    // Award a milestone
    func awardMilestone(_ percentage: Int) {
        let milestoneString = "\(percentage)%"
        if !achievedMilestones.contains(milestoneString) {
            achievedMilestones.append(milestoneString)
        }
    }
    
    // Check if challenge should be marked complete
    func checkCompletion(currentPages: Int) {
        if currentPages >= targetPages && status == .active {
            status = .completed
            completedDate = Date()
        } else if Date() > endDate && currentPages < targetPages && status == .active {
            status = .failed
        }
    }
}

enum ChallengeStatus: String, CaseIterable, Codable, Hashable {
    case active = "Active"
    case completed = "Completed"
    case failed = "Failed"
    case paused = "Paused"
    
    var systemImage: String {
        switch self {
        case .active:
            return "target"
        case .completed:
            return "checkmark.circle.fill"
        case .failed:
            return "xmark.circle.fill"
        case .paused:
            return "pause.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .active:
            return ColorPalette().deep
        case .completed:
            return .green
        case .failed:
            return .red
        case .paused:
            return .orange
        }
    }
}

// MARK: - Challenge Milestone Helpers
extension Challenge {
    static let milestonePercentages = [25, 50, 75, 100]
    
    func getNextMilestone(currentPages: Int) -> Int? {
        let currentProgress = Double(currentPages) / Double(targetPages) * 100.0
        
        return Challenge.milestonePercentages.first { milestone in
            let milestoneString = "\(milestone)%"
            return Double(milestone) > currentProgress && !achievedMilestones.contains(milestoneString)
        }
    }
    
    func getMilestonePages(percentage: Int) -> Int {
        return Int(Double(targetPages) * Double(percentage) / 100.0)
    }
}