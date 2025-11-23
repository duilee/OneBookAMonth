//
//  Constants.swift
//  OneBookAMonth
//
//  Created by delightroom on 3/25/25.
//

import Foundation
import SwiftData
import SwiftUI

// Time period enum for stats
enum TimePeriod: String, CaseIterable {
    case day = "D"
    case week = "W"
    case month = "M"
    case all = "All"
    
    static var mainCases: [TimePeriod] {
        return [.week, .month, .all]
    }
}

// case for completed view setting
enum CompletedStatus: String, CaseIterable {
    case ongoing = "Ongoing"
    case completed = "Completed"
}

// MARK: - Design System
// Colors, Typography, Spacing, Icons, and View Modifiers are now in the Design/ folder
// Import from: AppColors, AppTypography, Spacing, AppIcons, ButtonStyles, ViewModifiers
