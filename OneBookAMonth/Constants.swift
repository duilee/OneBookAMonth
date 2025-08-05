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
    let light = Color(red: 84/255, green: 139/255, blue: 209/255)
    let medium = Color(red: 65/255, green: 117/255, blue: 194/255)
    let deep = Color(red: 45/255, green: 95/255, blue: 172/255)
}
