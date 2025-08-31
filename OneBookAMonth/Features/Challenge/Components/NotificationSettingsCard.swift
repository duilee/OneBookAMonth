//
//  NotificationSettingsCard.swift
//  OneBookAMonth
//
//  Created by Claude on 2025-08-31.
//

import SwiftUI

struct NotificationSettingsCard: View {
    let challenge: Challenge
    @Bindable var viewModel: ChallengeViewModel
    
    private let primaryColor = Color(red: 25/255, green: 45/255, blue: 155/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with toggle
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Reading Reminders")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Get nudged to maintain your reading streak")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Toggle("", isOn: $viewModel.notificationsEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: primaryColor))
                    .onChange(of: viewModel.notificationsEnabled) { _, _ in
                        viewModel.updateNotificationSettings()
                    }
            }
            
            // Time picker and preview (only when enabled)
            if viewModel.notificationsEnabled {
                VStack(alignment: .leading, spacing: 12) {
                    // Time picker section
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                            .foregroundColor(primaryColor)
                            .frame(width: 20)
                        Text("Reminder Time")
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                        DatePicker("",
                                  selection: $viewModel.notificationTime,
                                  displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .onChange(of: viewModel.notificationTime) { _, _ in
                                viewModel.updateNotificationSettings()
                            }
                    }
                    
                    // Preview message
                    NotificationPreviewCard(
                        time: viewModel.notificationTime,
                        message: viewModel.getNotificationPreviewMessage()
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.3), value: viewModel.notificationsEnabled)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct NotificationPreviewCard: View {
    let time: Date
    let message: String
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "bell.badge")
                .font(.system(size: 12))
                .foregroundColor(.orange)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Preview: Daily at \(timeString)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Time to Read! 📚")
                        .font(.system(size: 12, weight: .semibold))
                    Text(message)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            NotificationSettingsCard(
                challenge: Challenge(
                    name: "Read 10 Books",
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(30 * 24 * 60 * 60),
                    targetPages: 3000
                ),
                viewModel: ChallengeViewModel()
            )
            .padding()
        }
    }
    .background(Color(.systemGray6))
}