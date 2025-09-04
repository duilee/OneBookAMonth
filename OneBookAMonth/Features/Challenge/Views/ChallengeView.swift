//
//  ChallengeView.swift
//  OneBookAMonth
//
//  Created by Claude on 2025-08-31.
//

import SwiftUI
import SwiftData

struct ChallengeView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedTab: Int
    @State private var viewModel = ChallengeViewModel()
    @State private var showCreateChallenge = false
    @State private var showCancelConfirmation = false
    @State private var showPastChallenges = false
    
    private let primaryColor = Color(red: 25/255, green: 45/255, blue: 155/255)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Challenge")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.black)
                        
                        Spacer()
                        
                        if viewModel.activeChallenge != nil {
                            Menu {
                                Button(role: .destructive) {
                                    showCancelConfirmation = true
                                } label: {
                                    Label("Cancel Challenge", systemImage: "xmark.circle")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(primaryColor)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    if let challenge = viewModel.activeChallenge,
                       let progress = viewModel.challengeProgress {
                        // Active Challenge Content
                        VStack(spacing: 24) {
                            // Progress Ring
                            ChallengeProgressRing(
                                progress: progress.progress,
                                pagesRead: progress.pagesRead,
                                targetPages: progress.targetPages,
                                size: 220
                            )
                            .padding(.vertical, 20)
                            
                            // Motivational Message
                            Text(viewModel.getMotivationalMessage())
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            // Continue Reading Button
                            Button(action: {
                                selectedTab = 0  // Switch to Library tab
                            }) {
                                HStack {
                                    Image(systemName: "book.fill")
                                    Text("Continue Reading")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(primaryColor)
                                .cornerRadius(25)
                            }
                            
                            
                            // Today's Progress
                            HStack(spacing: 20) {
                                TodayProgressCard(
                                    pagesRead: viewModel.todayPages,
                                    dailyGoal: progress.dailyPagesNeeded
                                )
                                
                                StreakCard(streak: progress.currentStreak)
                            }
                            .padding(.horizontal)
                            
                            // Challenge Details Card
                            ChallengeCard(
                                challenge: challenge,
                                progress: progress
                            )
                            .padding(.horizontal)
                            
                            // Notification Settings Section
                            VStack(spacing: 16) {
                                
                                NotificationSettingsCard(
                                    challenge: challenge,
                                    viewModel: viewModel
                                )
                            }
                            .padding(.horizontal)
                            
                            // Past Challenges Section - Collapsible
                            if !viewModel.pastChallenges.isEmpty {
                                VStack(spacing: 0) {
                                    // Divider with some spacing
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(height: 1)
                                        .padding(.vertical, 20)
                                    
                                    // Collapsible Header
                                    Button(action: { 
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            showPastChallenges.toggle()
                                        }
                                    }) {
                                        HStack {
                                            Text("Past Challenges")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 4) {
                                                if !showPastChallenges {
                                                    Text("\(viewModel.pastChallenges.count)")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 2)
                                                        .background(
                                                            Capsule()
                                                                .fill(Color.gray.opacity(0.3))
                                                        )
                                                }
                                                
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.secondary)
                                                    .rotationEffect(.degrees(showPastChallenges ? 90 : 0))
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    
                                    if showPastChallenges {
                                        VStack(spacing: 12) {
                                            ForEach(Array(viewModel.pastChallenges.prefix(5)), id: \.challenge.id) { item in
                                                PastChallengeCard(
                                                    challenge: item.challenge,
                                                    progress: item.progress,
                                                    onDelete: {
                                                        viewModel.deleteChallenge(item.challenge)
                                                    }
                                                )
                                                .transition(.asymmetric(
                                                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                                                    removal: .scale(scale: 0.8).combined(with: .opacity)
                                                ))
                                            }
                                            
                                            if viewModel.pastChallenges.count > 5 {
                                                Text("\(viewModel.pastChallenges.count - 5) more challenges")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.secondary)
                                                    .padding(.top, 8)
                                            }
                                        }
                                        .padding(.top, 16)
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
//                            // Quick Stats
//                            VStack(spacing: 16) {
//                                Text("Challenge Stats")
//                                    .font(.system(size: 18, weight: .semibold))
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                
//                                LazyVGrid(columns: [
//                                    GridItem(.flexible()),
//                                    GridItem(.flexible())
//                                ], spacing: 16) {
//                                    QuickStatCard(
//                                        title: "Avg. Daily",
//                                        value: "\(Int(progress.averagePagesPerDay))",
//                                        subtitle: "pages/day",
//                                        icon: "chart.line.uptrend.xyaxis",
//                                        color: .blue
//                                    )
//                                    
//                                    QuickStatCard(
//                                        title: "Reading Days",
//                                        value: "\(progress.readingDays)",
//                                        subtitle: "of \(progress.daysElapsed)",
//                                        icon: "calendar",
//                                        color: .green
//                                    )
//                                    
//                                    QuickStatCard(
//                                        title: "Status",
//                                        value: viewModel.getStatusText(),
//                                        subtitle: "",
//                                        icon: "flag.fill",
//                                        color: viewModel.getStatusColor()
//                                    )
//                                    
//                                    QuickStatCard(
//                                        title: "Time Left",
//                                        value: "\(progress.daysRemaining)",
//                                        subtitle: "days",
//                                        icon: "clock.fill",
//                                        color: .orange
//                                    )
//                                }
//                            }
//                            .padding(.horizontal)
                        }
                    } else {
                        // No Active Challenge
                        VStack(spacing: 24) {
                            // Compact Empty State Header
                            VStack(spacing: 16) {
                                Image(systemName: "trophy.circle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.3))
                                
                                Text("Ready for a new challenge?")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Button(action: {
                                    showCreateChallenge = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Create Challenge")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(primaryColor)
                                    .cornerRadius(25)
                                }
                            }
                            .padding(.vertical, 20)
                            
                            // Past Challenges Section (always visible when no active)
                            if !viewModel.pastChallenges.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Text("Your Challenge History")
                                            .font(.system(size: 18, weight: .semibold))
                                        
                                        Spacer()
                                    }
                                    
                                    // Stats Summary Card
                                    if viewModel.completedChallengesCount > 0 {
                                        HStack(spacing: 20) {
                                            StatSummaryItem(
                                                value: "\(viewModel.completedChallengesCount)",
                                                label: "Completed",
                                                color: .green
                                            )
                                            
                                            StatSummaryItem(
                                                value: "\(viewModel.totalBooksRead)",
                                                label: "Books Read",
                                                color: .blue
                                            )
                                            
                                            if viewModel.bestStreak > 0 {
                                                StatSummaryItem(
                                                    value: "\(viewModel.bestStreak)",
                                                    label: "Best Streak",
                                                    color: .orange
                                                )
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.secondarySystemBackground))
                                        )
                                    }
                                    
                                    // Challenge Cards
                                    VStack(spacing: 12) {
                                        ForEach(viewModel.pastChallenges, id: \.challenge.id) { item in
                                            PastChallengeEnhancedCard(
                                                challenge: item.challenge,
                                                progress: item.progress,
                                                onDelete: {
                                                    viewModel.deleteChallenge(item.challenge)
                                                }
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            } else {
                                // True empty state (no challenges ever)
                                VStack(spacing: 12) {
                                    Text("No challenges yet")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    Text("Start your first reading challenge\nand build a reading habit")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.top, 20)
                            }
                            
                            Spacer(minLength: 40)
                        }
                        .frame(maxWidth: .infinity)
                    }
            }
            .padding(.bottom, 60)
        }
        .onAppear {
            viewModel.setup(with: modelContext)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            // Refresh when Challenge tab (tag 1) is selected
            if newValue == 1 {
                viewModel.refreshData()
            }
        }
        .sheet(isPresented: $showCreateChallenge) {
            CreateChallengeView(
                isPresented: $showCreateChallenge,
                viewModel: viewModel
            )
            .onDisappear {
                viewModel.refreshData()
            }
        }
        .alert("Cancel Challenge", isPresented: $showCancelConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Yes, Cancel Challenge", role: .destructive) {
                viewModel.cancelChallenge()
            }
        } message: {
            Text("Are you sure you want to cancel this challenge? This action cannot be undone.")
        }
    }
}

struct TodayProgressCard: View {
    let pagesRead: Int
    let dailyGoal: Int
    
    private var progress: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(1.0, Double(pagesRead) / Double(dailyGoal))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center) {
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                    .frame(width: 14, height: 14)
                Text("Today")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(pagesRead)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                Text("of \(dailyGoal) pages")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
//            // Progress bar
//            GeometryReader { geometry in
//                ZStack(alignment: .leading) {
//                    RoundedRectangle(cornerRadius: 2)
//                        .fill(Color.gray.opacity(0.2))
//                        .frame(height: 4)
//                    
//                    RoundedRectangle(cornerRadius: 2)
//                        .fill(progress >= 1.0 ? Color.green : Color.blue)
//                        .frame(width: geometry.size.width * progress, height: 4)
//                }
//            }
//            .frame(height: 4)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct StreakCard: View {
    let streak: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                    .frame(width: 14, height: 14)
                Text("Streak")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(streak)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    Text("days")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Text(getStreakMessage())
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private func getStreakMessage() -> String {
        switch streak {
        case 0: return "Start reading today!"
        case 1: return "Great start!"
        case 2...6: return "Building momentum!"
        case 7...13: return "One week strong!"
        case 14...29: return "Two weeks! Amazing!"
        case 30...59: return "One month streak!"
        default: return "Legendary reader!"
        }
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    ChallengeView(selectedTab: .constant(1))
        .modelContainer(for: [Challenge.self, Item.self])
}
