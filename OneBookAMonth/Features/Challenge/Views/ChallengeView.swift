//
//  ChallengeView.swift
//  OneBookAMonth
//
//  Created by delightroom on 3/30/25.
//

import SwiftUI
import SwiftData

struct ChallengeView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @Query private var challenges: [Challenge]
    
    @State private var itemManager: ItemManager?
    @State private var challengeManager: ChallengeManager?
    @State private var showingCreateChallenge = false
    @State private var activeChallenge: Challenge?
    @State private var challengeProgress: ChallengeProgress?
    @State private var challengeStats: ChallengeStats?
    @State private var refreshTrigger = UUID()
    @State private var showingMilestoneAchievement = false
    @State private var newMilestones: [Int] = []
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                HStack {
                    Text("Challenge")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.black)
                    
                    Spacer()
                    
                    if activeChallenge == nil {
                        Button(action: {
                            showingCreateChallenge = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(ColorPalette().deep)
                        }
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 16)
                
                ScrollView {
                    VStack(spacing: 20) {
                        if let challenge = activeChallenge,
                           let progress = challengeProgress {
                            // Active Challenge Card
                            ChallengeCard(
                                challenge: challenge,
                                progress: progress,
                                stats: challengeStats
                            )
                            .padding(.horizontal, 16)
                            
                            // Progress Details
                            ChallengeProgressDetails(
                                challenge: challenge,
                                progress: progress
                            )
                            .padding(.horizontal, 16)
                            
                            // Milestones Section
                            MilestonesSection(
                                challenge: challenge,
                                progress: progress
                            )
                            .padding(.horizontal, 16)
                            
                        } else {
                            // No Active Challenge State
                            NoActiveChallengeView {
                                showingCreateChallenge = true
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        Spacer(minLength: 100) // Bottom padding for tab bar
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                setupManagers()
                loadActiveChallenge()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                loadActiveChallenge()
            }
            .sheet(isPresented: $showingCreateChallenge) {
                CreateChallengeView()
                    .onDisappear {
                        loadActiveChallenge()
                    }
            }
            .alert("Milestone Achieved!", isPresented: $showingMilestoneAchievement) {
                Button("Awesome!") {
                    newMilestones.removeAll()
                }
            } message: {
                if newMilestones.count == 1 {
                    Text("Congratulations! You've reached \(newMilestones.first!)% of your challenge goal!")
                } else if newMilestones.count > 1 {
                    Text("Amazing! You've achieved multiple milestones: \(newMilestones.map { "\($0)%" }.joined(separator: ", "))")
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupManagers() {
        if itemManager == nil {
            itemManager = ItemManager(modelContext: modelContext)
        }
        if challengeManager == nil {
            challengeManager = ChallengeManager(modelContext: modelContext)
        }
    }
    
    private func loadActiveChallenge() {
        guard let manager = challengeManager else { return }
        
        activeChallenge = manager.getActiveChallenge()
        
        if let challenge = activeChallenge {
            let progress = manager.calculateChallengeProgress(challenge, items: items)
            challengeProgress = progress
            challengeStats = manager.getChallengeStats(challenge, items: items)
            
            // Check for new milestones and show celebration
            if !progress.newMilestones.isEmpty {
                newMilestones = progress.newMilestones
                showingMilestoneAchievement = true
            }
            
            // Update completion status
            manager.updateChallengeCompletion(challenge, currentPages: progress.currentPages)
        }
        
        refreshTrigger = UUID()
    }
}

// MARK: - Supporting Views

private struct NoActiveChallengeView: View {
    let onCreateChallenge: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Illustration
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(ColorPalette().medium)
                .padding(.top, 40)
            
            VStack(spacing: 12) {
                Text("No Active Challenge")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Set a reading goal and track your progress with challenges!")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Button(action: onCreateChallenge) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                    
                    Text("Create Challenge")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(ColorPalette().deep)
                .cornerRadius(16)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
    }
}

private struct ChallengeProgressDetails: View {
    let challenge: Challenge
    let progress: ChallengeProgress
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Label {
                    Text("Details")
                        .font(.system(size: 18, weight: .semibold))
                } icon: {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(ColorPalette().deep)
                }
                Spacer()
            }
            
            // Details Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                DetailStatView(
                    title: "Days Remaining",
                    value: "\(progress.daysRemaining)",
                    icon: "calendar",
                    color: progress.daysRemaining > 7 ? ColorPalette().medium : .orange
                )
                
                DetailStatView(
                    title: "Pages Left",
                    value: "\(progress.pagesRemaining)",
                    icon: "book.pages",
                    color: ColorPalette().medium
                )
                
                DetailStatView(
                    title: "Daily Goal",
                    value: "\(Int(progress.dailyAverageNeeded.rounded()))",
                    icon: "target",
                    color: progress.dailyAverageNeeded > 50 ? .orange : ColorPalette().deep
                )
                
                DetailStatView(
                    title: "Progress",
                    value: "\(Int(progress.progressPercentage * 100))%",
                    icon: "chart.bar.fill",
                    color: .green
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
    }
}

private struct DetailStatView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct MilestonesSection: View {
    let challenge: Challenge
    let progress: ChallengeProgress
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Label {
                    Text("Milestones")
                        .font(.system(size: 18, weight: .semibold))
                } icon: {
                    Image(systemName: "rosette")
                        .font(.system(size: 16))
                        .foregroundColor(ColorPalette().deep)
                }
                Spacer()
            }
            
            // Milestones Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(Challenge.milestonePercentages, id: \.self) { percentage in
                    MilestoneView(
                        percentage: percentage,
                        targetPages: challenge.targetPages,
                        currentPages: progress.currentPages,
                        isAchieved: challenge.achievedMilestones.contains("\(percentage)%")
                    )
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
    }
}

private struct MilestoneView: View {
    let percentage: Int
    let targetPages: Int
    let currentPages: Int
    let isAchieved: Bool
    
    private var pagesNeeded: Int {
        Int(Double(targetPages) * Double(percentage) / 100.0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isAchieved ? .green : Color(.systemGray5))
                    .frame(width: 50, height: 50)
                
                Image(systemName: isAchieved ? "checkmark" : "target")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isAchieved ? .white : .secondary)
            }
            
            Text("\(percentage)%")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isAchieved ? .green : .primary)
            
            Text("\(pagesNeeded) pages")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, Challenge.self, PageEntry.self, Memo.self, configurations: config)
    let context = container.mainContext
    
    // Create sample challenge
    let challenge = Challenge(
        name: "March Reading Challenge",
        targetPages: 1000,
        startDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()) ?? Date()
    )
    context.insert(challenge)
    
    // Create sample books with page entries to show realistic progress
    let book1 = Item(
        timestamp: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
        name: "Sample Book 1",
        numberOfPages: 300
    )
    book1.currentPage = 180
    book1.addPagesForDate(Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), book1, pages: 50)
    book1.addPagesForDate(Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), book1, pages: 120)
    book1.addPagesForDate(Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), book1, pages: 180)
    context.insert(book1)
    
    let book2 = Item(
        timestamp: Calendar.current.date(byAdding: .day, value: -12, to: Date()) ?? Date(),
        name: "Sample Book 2",
        numberOfPages: 450
    )
    book2.currentPage = 280
    book2.addPagesForDate(Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(), book2, pages: 80)
    book2.addPagesForDate(Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), book2, pages: 200)
    book2.addPagesForDate(Date(), book2, pages: 280)
    context.insert(book2)
    
    // Save the context to ensure all relationships are properly set up
    try? context.save()
    
    return ChallengeView()
        .modelContainer(container)
}