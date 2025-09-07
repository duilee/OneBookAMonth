//
//  FocusTimerViewModel.swift
//  OneBookAMonth
//
//  Created by Assistant on 2025-09-06.
//

import SwiftUI
import SwiftData
import UIKit
import Combine

class FocusTimerViewModel: ObservableObject {
    // Timer state
    private var timer: Timer?
    private var screenKeepAliveTimer: Timer?
    private var startTime: Date?
    private var accumulatedTime: TimeInterval = 0
    
    // Observable properties
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var currentSessionTime: TimeInterval = 0
    @Published var todaysTotalTime: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0
    
    // Warning states
    @Published var showBatteryWarning = false
    @Published var showLongSessionWarning = false
    
    // Constants
    private let warningThreshold: TimeInterval = 3600 // 1 hour
    private let maxSessionTime: TimeInterval = 7200 // 2 hours
    
    init() {
        // Initialize with current values if needed
    }
    
    deinit {
        // Ensure cleanup on deallocation
        if isRunning {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        timer?.invalidate()
        screenKeepAliveTimer?.invalidate()
    }
    
    // MARK: - Timer Controls
    
    func start(item: Item, modelContext: ModelContext) {
        guard !isRunning else { return }
        
        // Check for interrupted session
        if let sessionStart = item.currentFocusSessionStart {
            // There was an interrupted session
            let elapsedSinceStart = Date().timeIntervalSince(sessionStart)
            if elapsedSinceStart < 3600 { // If less than 1 hour, assume it's resumable
                accumulatedTime = elapsedSinceStart
                startTime = sessionStart
            } else {
                // Too old, start fresh
                item.currentFocusSessionStart = Date()
                startTime = Date()
                accumulatedTime = 0
            }
        } else {
            startTime = Date()
            item.currentFocusSessionStart = Date()
            accumulatedTime = 0
        }
        
        isRunning = true
        isPaused = false
        
        // Load today's total from item
        todaysTotalTime = item.todaysFocusTime
        totalTime = item.totalFocusedReadingTime ?? 0
        
        // Save the session start
        do {
            try modelContext.save()
        } catch {
            print("Failed to save session start: \(error)")
        }
        
        // Keep screen on - set immediately without async
        UIApplication.shared.isIdleTimerDisabled = true
        print("🟢 Focus Timer: Screen wake lock ENABLED")
        
        // Start main timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTime(item: item)
        }
        
        // Start screen keep-alive safety timer (re-enables every 30 seconds as backup)
        screenKeepAliveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.isRunning && !self.isPaused {
                let wasDisabled = UIApplication.shared.isIdleTimerDisabled
                UIApplication.shared.isIdleTimerDisabled = true
                if !wasDisabled {
                    print("⚠️ Focus Timer: Screen wake lock was OFF, re-enabled it")
                }
            }
        }
    }
    
    func pause() {
        guard isRunning && !isPaused else { return }
        
        isPaused = true
        timer?.invalidate()
        timer = nil
        
        // Calculate accumulated time
        if let start = startTime {
            accumulatedTime += Date().timeIntervalSince(start)
        }
        
        // Keep screen on even when paused (user might be reading)
        // They can manually lock if needed
    }
    
    func resume(item: Item) {
        guard isRunning && isPaused else { return }
        
        isPaused = false
        startTime = Date()
        
        // Restart timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTime(item: item)
        }
    }
    
    func stop(item: Item, modelContext: ModelContext) {
        guard isRunning else { return }
        
        // Calculate final session time
        if !isPaused, let start = startTime {
            accumulatedTime += Date().timeIntervalSince(start)
        }
        
        currentSessionTime = accumulatedTime
        
        // Save to model
        saveToItem(item, modelContext: modelContext)
        
        // Reset state
        isRunning = false
        isPaused = false
        timer?.invalidate()
        timer = nil
        screenKeepAliveTimer?.invalidate()
        screenKeepAliveTimer = nil
        startTime = nil
        accumulatedTime = 0
        currentSessionTime = 0
        item.currentFocusSessionStart = nil
        
        // Re-enable auto-lock - set immediately without async
        UIApplication.shared.isIdleTimerDisabled = false
        print("🔴 Focus Timer: Screen wake lock DISABLED")
        
        // Reset warnings
        showBatteryWarning = false
        showLongSessionWarning = false
    }
    
    // MARK: - Private Methods
    
    private func updateTime(item: Item) {
        guard isRunning, !isPaused, let start = startTime else { return }
        
        let elapsed = Date().timeIntervalSince(start)
        currentSessionTime = accumulatedTime + elapsed
        
        // Update today's total for display
        todaysTotalTime = item.todaysFocusTime + currentSessionTime
        
        // Check for warnings
        if currentSessionTime > warningThreshold && !showBatteryWarning {
            showBatteryWarning = true
        }
        
        if currentSessionTime > maxSessionTime && !showLongSessionWarning {
            showLongSessionWarning = true
            // Optionally auto-stop after 2 hours
            // stop(item: item, modelContext: modelContext)
        }
    }
    
    private func saveToItem(_ item: Item, modelContext: ModelContext) {
        // Add the session time to the item
        item.addFocusTime(currentSessionTime)
        
        // Clear session start
        item.currentFocusSessionStart = nil
        
        // Update our display values
        todaysTotalTime = item.todaysFocusTime
        totalTime = item.totalFocusedReadingTime ?? 0
        
        // Save changes
        do {
            try modelContext.save()
        } catch {
            print("Failed to save focus time: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func formatShortTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(hours)h"
            }
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            let seconds = Int(timeInterval) % 60
            return "\(seconds)s"
        }
    }
    
    // MARK: - Lifecycle Management
    
    func handleScenePhaseChange(_ phase: ScenePhase, item: Item, modelContext: ModelContext) {
        switch phase {
        case .background:
            // App going to background
            if isRunning && !isPaused {
                // Save current state but don't stop timer
                // This allows for brief interruptions
                if let start = startTime {
                    let currentAccumulated = accumulatedTime + Date().timeIntervalSince(start)
                    item.addFocusTime(currentAccumulated)
                    
                    // Reset accumulator but keep timer "running"
                    accumulatedTime = 0
                    startTime = Date()
                    
                    do {
                        try modelContext.save()
                    } catch {
                        print("Failed to save on background: \(error)")
                    }
                }
            }
            // Temporarily disable screen wake lock when backgrounded
            UIApplication.shared.isIdleTimerDisabled = false
            print("🟡 Focus Timer: App backgrounded, screen wake lock temporarily disabled")
            
        case .inactive:
            // Prepare for background or foreground
            break
            
        case .active:
            // App became active
            if isRunning && !isPaused {
                // Re-enable screen wake lock when returning to foreground
                UIApplication.shared.isIdleTimerDisabled = true
                print("🟢 Focus Timer: App active, screen wake lock re-enabled")
                
                // Refresh today's total
                todaysTotalTime = item.todaysFocusTime
                totalTime = item.totalFocusedReadingTime ?? 0
            }
            
        @unknown default:
            break
        }
    }
    
    func handleViewDisappear(item: Item, modelContext: ModelContext) {
        // When leaving the view, stop timer and save
        if isRunning {
            stop(item: item, modelContext: modelContext)
        }
        
        // Always ensure screen lock is re-enabled
        UIApplication.shared.isIdleTimerDisabled = false
        print("🔴 Focus Timer: View disappeared, screen wake lock disabled")
    }
    
    // Load initial values when view appears
    func loadInitialValues(from item: Item) {
        todaysTotalTime = item.todaysFocusTime
        totalTime = item.totalFocusedReadingTime ?? 0
    }
}