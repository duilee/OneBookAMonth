//
//  ContentView.swift
//  ABookAMonth
//
//  Created by delightroom on 1/30/25.
//

import SwiftUI
import SwiftData
import HorizonCalendar

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var items: [Item]
    
    @State private var selectedTab = 0
    @State private var currentDate = Date()
    
    private var itemManager: ItemManager {
            ItemManager(modelContext: modelContext)
        }
    
    var body: some View {
        TabView(selection: $selectedTab) {

            LibraryView()
                .tabItem {
                    Label("Readings", systemImage: "book")
                }
                .tag(0)
            
            ChallengeView()
                .tabItem {
                    Label("Challenge", systemImage: "target")
                }
                .tag(1)
            
            StatsView(selectedTab: $selectedTab, currentDate: $currentDate)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
                .tag(2)
            
//            StatsViewModel(currentDate: $currentDate)
//                .tabItem {
//                    Label("Stats", systemImage: "chart.bar")
//                }
//                .tag(2)
        }
        .accentColor(.blue) // Customize selected tab color
        .onChange(of: selectedTab) { oldValue, newValue in
                    currentDate = Date()
                }
        .onChange(of: scenePhase) { oldPhase, newPhase in
                    if newPhase == .active && oldPhase != .active {
                        // App moved to foreground - update date
                        currentDate = Date()
                    }
                }
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = .systemBackground
            
            // For iOS 15 and later
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .colorScheme(.light)
        
    }

}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, Challenge.self, PageEntry.self, Memo.self, configurations: config)
    let context = container.mainContext
    
    // Create sample data
    let manager = ItemManager(modelContext: context)
    
    // Add sample books
    manager.addItem(name: "The Great Gatsby", numberOfPages: 100)
    manager.addItem(name: "1984", numberOfPages: 328)
    manager.addItem(name: "1Q84", numberOfPages: 450)
    
//    // Create sample challenge
//    let challengeManager = ChallengeManager(modelContext: context)
//    let _ = try! challengeManager.createChallenge(
//        name: "March Reading Challenge",
//        targetPages: 1000,
//        startDate: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date(),
//        endDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()) ?? Date()
//    )
    
    return ContentView()
        .modelContainer(container)
}
