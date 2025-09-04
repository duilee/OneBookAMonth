import SwiftUI
import SwiftData

struct ReminderStepView: View {
    let viewModel: OnboardingViewModel
    let onComplete: () -> Void
    let onSkip: () -> Void
    
    @State private var enableReminders = true
    @State private var selectedTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var notificationRequested = false
    @Environment(\.modelContext) private var modelContext
    @State private var challengeManager: ChallengeManager?
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 80))
                .foregroundStyle(.tint)
            
            VStack(spacing: 12) {
                Text("Stay on Track")
                    .font(.title)
                    .fontWeight(.bold)
                
                if let challenge = viewModel.createdChallenge {
                    Text("Get daily reminders for your \(challenge.name)")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Get daily reminders to keep reading")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                Toggle(isOn: $enableReminders) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(.tint)
                        Text("Daily Reading Reminder")
                            .font(.body)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                if enableReminders {
                    DatePicker("Reminder Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    if viewModel.createdChallenge != nil {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.secondary)
                            Text("Reminders will be active during your challenge period")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: completeSetup) {
                Text(enableReminders ? "Enable & Start Reading" : "Start Reading")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .padding()
        .onAppear {
            if challengeManager == nil {
                challengeManager = ChallengeManager(modelContext: modelContext)
            }
        }
    }
    
    private func completeSetup() {
        if let challenge = viewModel.createdChallenge {
            challenge.notificationsEnabled = enableReminders
            challenge.notificationTime = selectedTime
            
            do {
                try modelContext.save()
            } catch {
                print("Failed to save challenge notification settings: \(error)")
            }
            
            if enableReminders && !notificationRequested {
                Task {
                    let granted = await NotificationManager.shared.requestPermission()
                    if granted, let manager = challengeManager {
                        let progress = manager.calculateProgress(for: challenge)
                        let todayPages = manager.getTodayPages(for: challenge)
                        
                        await NotificationManager.shared.scheduleChallengeNotifications(
                            for: challenge,
                            progress: progress,
                            todayPages: todayPages
                        )
                    }
                    notificationRequested = true
                    await MainActor.run {
                        onComplete()
                    }
                }
            } else {
                onComplete()
            }
        } else {
            onComplete()
        }
    }
}