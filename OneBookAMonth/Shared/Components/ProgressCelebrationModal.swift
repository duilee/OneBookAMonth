//
//  ProgressCelebrationModal.swift
//  OneBookAMonth
//
//  Created by Assistant on 2025-09-06.
//

import SwiftUI

struct ProgressCelebrationModal: View {
    let context: CelebrationContext
    @Binding var isPresented: Bool
    
    // Auto-dismiss timer
    @State private var dismissTimer: Timer?
    @State private var animationScale: CGFloat = 0.8
    @State private var animationOpacity: Double = 0.0
    
    // MARK: - Spacing Constants (8pt Grid System)
    private let spacing = (
        xs: CGFloat(4),
        sm: CGFloat(8),
        md: CGFloat(16),
        lg: CGFloat(24),
        xl: CGFloat(32)
    )
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }
                .opacity(animationOpacity)
            
            VStack(spacing: spacing.lg) {
                // Main celebration content
                celebrationCard
            }
            .scaleEffect(animationScale)
            .opacity(animationOpacity)
        }
        .onAppear {
            startAnimations()
            startAutoDismissTimer()
        }
        .onDisappear {
            dismissTimer?.invalidate()
        }
    }
    
    private var celebrationCard: some View {
        VStack(spacing: spacing.lg) {
            // Celebration header
            celebrationHeader
            
            // Progress stats
            progressStats
            
            // Action buttons
            actionButtons
        }
        .padding(spacing.lg)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .frame(maxWidth: 340)
    }
    
    private var celebrationHeader: some View {
        VStack(spacing: spacing.md) {
            // Animated emoji
            Text(primaryEmoji)
                .font(.system(size: 48))
                .scaleEffect(animationScale * 1.2)
                .animation(.spring(duration: 0.6, bounce: 0.4).delay(0.2), value: animationScale)
            
            // Title
            Text(celebrationTitle)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            // Subtitle
            if let subtitle = celebrationSubtitle {
                Text(subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var progressStats: some View {
        VStack(spacing: spacing.sm) {
            // Pages read today
            StatRow(
                icon: "📚",
                text: "+\(context.pagesRead) pages",
                accent: context.pagesRead > 20
            )
            
            // Book progress
            if context.bookProgress > 0 {
                StatRow(
                    icon: "📊",
                    text: "\(Int(context.bookProgress * 100))% complete",
                    accent: hasBookMilestone
                )
            }
            
            // Streak
            if context.streakDays > 0 {
                StatRow(
                    icon: "🔥",
                    text: "\(context.streakDays)-day streak",
                    accent: context.isNewStreak && context.streakDays >= 3
                )
            }
            
            // Challenge progress
            if let challenge = context.challengeImpact {
                StatRow(
                    icon: "🎯",
                    text: "\(challenge.challengeName): \(challenge.daysCompleted)/\(challenge.daysTotal) days",
                    accent: challenge.justCompletedDay
                )
            }
        }
        .padding(spacing.md)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var actionButtons: some View {
        HStack(spacing: spacing.md) {
            // Continue button
            Button("Continue") {
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, spacing.md)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .font(.system(size: 16, weight: .medium))
            
        }
    }
    
    // MARK: - Computed Properties
    
    private var primaryEmoji: String {
        // Priority: milestones > challenge > streak > default
        if let milestone = context.milestones.first {
            return milestone.emoji
        } else if let challenge = context.challengeImpact, challenge.justCompletedDay {
            return "🎯"
        } else if context.isNewStreak && context.streakDays >= 7 {
            return "🔥"
        } else {
            return "🎉"
        }
    }
    
    private var celebrationTitle: String {
        // Priority: major milestones > challenges > streaks > default
        if let milestone = context.milestones.first {
            switch milestone {
            case .bookFinished:
                return "Book Completed!"
            case .bookHalf:
                return "Halfway There!"
            case .bookThreeQuarters:
                return "Almost Done!"
            case .streakMilestone(let days):
                return "\(days)-Day Streak!"
            case .personalBest:
                return "Personal Best!"
            default:
                return milestone.displayText
            }
        } else if let challenge = context.challengeImpact, challenge.justCompletedDay {
            return "Challenge Day Complete!"
        } else if context.isNewStreak && context.streakDays >= 3 {
            return "Streak Going Strong!"
        } else {
            return "Great Progress!"
        }
    }
    
    private var celebrationSubtitle: String? {
        if context.milestones.contains(where: { if case .bookFinished = $0 { return true }; return false }) {
            return "Time to pick your next book!"
        } else if let challenge = context.challengeImpact {
            if challenge.isOnTrack {
                return "You're on track to complete your challenge!"
            } else {
                return "Keep reading to stay on track!"
            }
        } else if context.streakDays >= 7 {
            return "You're building an amazing reading habit!"
        }
        return nil
    }
    
    private var hasBookMilestone: Bool {
        return context.milestones.contains { milestone in
            switch milestone {
            case .bookQuarter, .bookHalf, .bookThreeQuarters, .bookFinished:
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func startAnimations() {
        withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
            animationScale = 1.0
            animationOpacity = 1.0
        }
    }
    
    private func startAutoDismissTimer() {
        dismissTimer = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: false) { _ in
            if isPresented {
                dismiss()
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.3)) {
            animationScale = 0.8
            animationOpacity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}

// MARK: - Supporting Views

struct StatRow: View {
    let icon: String
    let text: String
    let accent: Bool
    
    init(icon: String, text: String, accent: Bool = false) {
        self.icon = icon
        self.text = text
        self.accent = accent
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 16))
            
            Text(text)
                .font(.system(size: 16, weight: accent ? .semibold : .medium))
                .foregroundColor(accent ? Color(red: 25/255, green: 45/255, blue: 155/255) : .primary)
            
            Spacer()
            
            if accent {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let context = CelebrationContext(
        pagesRead: 25,
        totalPagesToday: 35,
        bookProgress: 0.67,
        streakDays: 5,
        isNewStreak: true,
        challengeImpact: ChallengeImpact(
            challengeName: "January Challenge",
            daysCompleted: 12,
            daysTotal: 30,
            weekProgress: [true, true, true, false, false, false, false],
            daysRemaining: 18,
            isOnTrack: true,
            justCompletedDay: true
        ),
        milestones: [.bookHalf]
    )
    
    ProgressCelebrationModal(
        context: context,
        isPresented: .constant(true)
    )
}
