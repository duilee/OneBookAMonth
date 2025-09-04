import SwiftUI
import SwiftData

struct ChallengeStepView: View {
    let viewModel: OnboardingViewModel
    let modelContext: ModelContext
    
    let onNext: () -> Void
    let onSkip: () -> Void
    
    @State private var selectedDuration = 30
    @State private var targetPages: Int = 100
    @State private var targetPagesText: String = "100"
    @State private var challengeCreated = false
    @State private var challengeManager: ChallengeManager?
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundStyle(.tint)
            
            VStack(spacing: 16) {
                Text("Set a Reading Goal")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Start with a quick win challenge")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            if !challengeCreated {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Challenge Duration")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Picker("", selection: $selectedDuration) {
                            Text("7 days").tag(7)
                            Text("14 days").tag(14)
                            Text("30 days").tag(30)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target Pages")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            TextField("\(targetPages)", text: $targetPagesText)
                                .keyboardType(.numberPad)
                                .font(.headline)
                                .focused($isInputFocused)
                                .onChange(of: targetPagesText) { _, newValue in
                                    // Filter to only allow numbers
                                    let filtered = newValue.filter { $0.isNumber }
                                    if filtered != newValue {
                                        targetPagesText = filtered
                                    }
                                    // Update targetPages
                                    if let pages = Int(filtered), pages > 0 {
                                        targetPages = pages
                                    }
                                }
                            
                            Text("pages")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.secondary)
                        Text("That's about \(targetPages/selectedDuration) pages per day")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
                .padding(.horizontal, 40)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                    
                    Text("Challenge Created!")
                        .font(.headline)
                    
                    Text("\(selectedDuration)-day challenge • \(targetPages) pages")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 40)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                if !challengeCreated {
                    Button(action: createChallenge) {
                        Text("Create Challenge")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    Button(action: onNext) {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .padding()
        .onAppear {
            if challengeManager == nil {
                challengeManager = ChallengeManager(modelContext: modelContext)
            }
            
            // Always check for added book when view appears
            if let addedBook = viewModel.addedBook {
                targetPages = addedBook.numberOfPages
                targetPagesText = "\(addedBook.numberOfPages)"
            }
            
            if let manager = challengeManager {
                if let existingChallenge = manager.getActiveChallenge() {
                    viewModel.createdChallenge = existingChallenge
                    challengeCreated = true
                }
            }
        }
        .onChange(of: viewModel.addedBook) {
            // Always check for added book when view appears
            if let addedBook = viewModel.addedBook {
                targetPages = addedBook.numberOfPages
                targetPagesText = "\(addedBook.numberOfPages)"
            }
        }
        .onTapGesture {
            isInputFocused = false
        }
    }
    
    private func createChallenge() {
        guard let manager = challengeManager else { return }
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: selectedDuration, to: startDate) ?? Date()
        
        let challenge = manager.createChallenge(
            name: "My First Challenge",
            startDate: startDate,
            endDate: endDate,
            targetPages: targetPages
        )
        
        viewModel.createdChallenge = challenge
        
        withAnimation {
            challengeCreated = true
        }
    }
}
