//
//  Helpers.swift
//  OneBookAMonth
//
//  Created by delightroom on 3/9/25.
//

import Foundation
import SwiftData
import HorizonCalendar
import SwiftUI

// Helper to convert DayComponents to Date
func getDate(from day: DayComponents, from calendar: Calendar) -> Date {
    let components = DateComponents(
        year: day.month.year,
        month: day.month.month,
        day: day.day
    )
    return calendar.date(from: components) ?? Date()
}

// Calculate opacity based on count
func getOpacity(for count: Int) -> Double {
    let maxCount = 3
    let minOpacity = 0.4
    let maxOpacity = 0.7
    
    // Scale opacity between minOpacity and maxOpacity based on count
    return minOpacity + (Double(count) / Double(maxCount)) * (maxOpacity - minOpacity)
}

// Calculate Color based on count
func getColor(for count: Int) -> Color {
    if count >= 3 {
        return .primaryDeep
    } else if count >= 2 {
        return .primaryMedium
    } else {
        return .primaryLight
    }
}

// Date formatter utility function
func formatDate(_ date: Date, format: String = "MMM d yyyy") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
}
