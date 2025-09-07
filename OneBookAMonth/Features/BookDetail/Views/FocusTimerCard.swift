//
//  FocusTimerCard.swift
//  OneBookAMonth
//
//  Created by Assistant on 2025-09-06.
//

import SwiftUI
import SwiftData

struct FocusTimerCard: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var timerVM = FocusTimerViewModel()
    let item: Item
    
    // Animation states
    @State private var pulseAnimation = false
    @State private var showStopConfirmation = false
    
    // MARK: - Spacing Constants (8pt Grid System)
    private let spacing = (
        xs: CGFloat(4),
        sm: CGFloat(8),
        md: CGFloat(16),
        lg: CGFloat(24),
        xl: CGFloat(32)
    )
    
    var body: some View {
        VStack(spacing: spacing.md) {
            // Main timer card
            VStack(spacing: spacing.md) {
                // Header
                HStack {
                    HStack(spacing: spacing.sm) {
                        Image(systemName: timerVM.isRunning ? "timer" : "timer")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(timerVM.isRunning ? .green : Color(red: 25/255, green: 45/255, blue: 155/255))
                            .symbolEffect(.pulse, isActive: timerVM.isRunning && !timerVM.isPaused)
                        
                        Text("Focus Timer")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                    }
                    
                    Spacer()
                    
                    if timerVM.isRunning {
                        // Status indicator
                        HStack(spacing: spacing.xs) {
                            Circle()
                                .fill(timerVM.isPaused ? Color.orange : Color.green)
                                .frame(width: 8, height: 8)
                                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseAnimation)
                            
                            Text(timerVM.isPaused ? "Paused" : "Active")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(timerVM.isPaused ? .orange : .green)
                        }
                        .padding(.horizontal, spacing.sm)
                        .padding(.vertical, spacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill((timerVM.isPaused ? Color.orange : Color.green).opacity(0.1))
                        )
                    }
                }
                
                // Timer display
                VStack(spacing: spacing.sm) {
                    if timerVM.isRunning || timerVM.isPaused {
                        Text(timerVM.formatTime(timerVM.currentSessionTime))
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                        
                        Text("Current Session")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    } else {
                        VStack(spacing: spacing.xs) {
                            Text("Ready to Focus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Start timer when you're ready to read")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, spacing.sm)
                    }
                }
                
                // Control buttons
                HStack(spacing: spacing.md) {
                    if !timerVM.isRunning {
                        // Start button
                        Button(action: startTimer) {
                            HStack(spacing: spacing.sm) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 18))
                                Text("Start Focus")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        // Pause/Resume button
                        Button(action: togglePause) {
                            HStack(spacing: spacing.sm) {
                                Image(systemName: timerVM.isPaused ? "play.fill" : "pause.fill")
                                    .font(.system(size: 18))
                                Text(timerVM.isPaused ? "Resume" : "Pause")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Stop button
                        Button(action: {
                            if timerVM.currentSessionTime > 60 {
                                // Show confirmation if session > 1 minute
                                showStopConfirmation = true
                            } else {
                                stopTimer()
                            }
                        }) {
                            HStack(spacing: spacing.sm) {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 18))
                                Text("Stop")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Divider()
                
                // Statistics row
                HStack(spacing: spacing.md) {
                    // Today's time
                    VStack(alignment: .leading, spacing: spacing.xs) {
                        Label {
                            Text("Today")
                                .font(.system(size: 12, weight: .medium))
                        } icon: {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.secondary)
                        
                        Text(timerVM.formatShortTime(timerVM.todaysTotalTime))
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Total time
                    VStack(alignment: .trailing, spacing: spacing.xs) {
                        Label {
                            Text("Total")
                                .font(.system(size: 12, weight: .medium))
                        } icon: {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.secondary)
                        
                        Text(timerVM.formatShortTime(timerVM.totalTime))
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                }
                
                // Warnings
                if timerVM.showBatteryWarning {
                    HStack(spacing: spacing.sm) {
                        Image(systemName: "battery.25")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text("Screen staying on may drain battery")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                    }
                    .padding(spacing.sm)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                if timerVM.isRunning && !timerVM.showBatteryWarning {
                    HStack(spacing: spacing.sm) {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        Text("Screen will stay on during focus session")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                    .padding(spacing.sm)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(spacing.md)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
        .onAppear {
            timerVM.loadInitialValues(from: item)
            if timerVM.isRunning {
                pulseAnimation = true
            }
        }
        .onDisappear {
            timerVM.handleViewDisappear(item: item, modelContext: modelContext)
        }
        .onChange(of: scenePhase) { _, newPhase in
            timerVM.handleScenePhaseChange(newPhase, item: item, modelContext: modelContext)
        }
        .onChange(of: timerVM.isRunning) { _, isRunning in
            pulseAnimation = isRunning
        }
        .alert("Stop Focus Session?", isPresented: $showStopConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Stop", role: .destructive) {
                stopTimer()
            }
        } message: {
            Text("You've been focusing for \(timerVM.formatTime(timerVM.currentSessionTime)). Are you sure you want to stop?")
        }
    }
    
    // MARK: - Actions
    
    private func startTimer() {
        timerVM.start(item: item, modelContext: modelContext)
    }
    
    private func togglePause() {
        if timerVM.isPaused {
            timerVM.resume(item: item)
        } else {
            timerVM.pause()
        }
    }
    
    private func stopTimer() {
        timerVM.stop(item: item, modelContext: modelContext)
    }
}

#Preview {
    let newItem = Item(timestamp: Date(), name: "Sample Book", numberOfPages: 300)
    FocusTimerCard(item: newItem)
        .padding()
}