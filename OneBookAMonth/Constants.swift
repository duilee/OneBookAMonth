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

// Color Palette
struct ColorPalette {
    let light = Color(red: 150/255, green: 160/255, blue: 220/255)
    let medium = Color(red: 100/255, green: 110/255, blue: 190/255)
    let deep = Color(red: 25/255, green: 45/255, blue: 155/255)
}
