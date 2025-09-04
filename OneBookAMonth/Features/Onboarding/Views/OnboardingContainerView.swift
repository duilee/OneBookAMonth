import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @State private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        if viewModel.isOnboardingComplete {
            ContentView()
        } else {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                TabView(selection: $viewModel.currentStep) {
                    WelcomeStepView(onNext: viewModel.nextStep)
                        .tag(OnboardingStep.welcome)
                    
                    AddBookStepView(viewModel: viewModel, onNext: viewModel.nextStep, onSkip: viewModel.nextStep)
                        .tag(OnboardingStep.addBook)
                    
                    ChallengeStepView(viewModel: viewModel, modelContext: modelContext, onNext: viewModel.nextStep, onSkip: viewModel.nextStep)
                        .tag(OnboardingStep.challenge)
                    
                    ReminderStepView(viewModel: viewModel, onComplete: viewModel.completeOnboarding, onSkip: viewModel.completeOnboarding)
                        .tag(OnboardingStep.reminder)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .overlay(alignment: .topTrailing) {
                    if viewModel.currentStep.isSkippable {
                        Button("Skip") {
                            viewModel.nextStep()
                        }
                        .foregroundStyle(.secondary)
                        .padding()
                        .padding(.top, 10) // Account for safe area
                    }
                }
            }
        }
    }
}

#Preview {
    do {
        let schema = Schema([
            Item.self,
            PageEntry.self,
            Memo.self,
            Challenge.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        
        return OnboardingContainerView()
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
