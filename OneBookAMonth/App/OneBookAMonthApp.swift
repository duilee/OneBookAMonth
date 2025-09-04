//
//  OneBookAMonthApp.swift
//  OneBookAMonth
//
//  Created by delightroom on 2/15/25.
//

import SwiftUI
import SwiftData

@main
struct OneBookAMonthApp: App {
    @Environment(\.modelContext) private var modelContext
    @State private var isLoading = true
    @State private var showOnboarding = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            PageEntry.self,
            Memo.self,
            Challenge.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if isLoading {
                LoadingView()
                    .onAppear {
                        // Check onboarding status during loading
                        showOnboarding = OnboardingManager.shared.shouldShowOnboarding()
                        
                        // Simulate loading time or actual initialization
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            withAnimation {
                                isLoading = false
                            }
                        }
                    }
            } else if showOnboarding {
                OnboardingContainerView()
                    .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
