//
//  HomeViewModel2.swift
//  OneBookAMonth
//
//  Created by delightroom on 3/24/25.
//

import SwiftUI
import SwiftData

struct StatsViewModel: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @Binding var currentDate: Date
    @State private var selectedPeriod: TimePeriod = .week
    private var itemManager: ItemManager {
        ItemManager(modelContext: modelContext)
    }
    
    // Computed property to get incomplete items
    private var incompleteItems: [Item] {
        items.filter { $0.progress < 1.0 }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Activity")
                        .font(.system(size: 28, weight: .bold))
                    
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.horizontal, 16)
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        
                        
                        // Segmented Control
                        Picker("Time Period", selection: $selectedPeriod) {
                            ForEach(TimePeriod.mainCases, id: \.self) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 8)
                        
                        // Stats View
                        let stats = itemManager.getStats(for: items, period: selectedPeriod, selectedDate: currentDate)
                        VStack(spacing: 24) {
                            // Total Pages
                            VStack(spacing: 4) {
                                Text("\(stats.totalPages)")
                                    .font(.system(size: 48, weight: .bold))
                                Text("Pages Read")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Other Stats
                            HStack(spacing: 0) {
                                StatItemView(value: "\(stats.books)", label: "Books")
                                StatItemView(value: "\(stats.daysRead)", label: "Days Read")
                                StatItemView(value: String(format: "%.0f", stats.avgPages), label: "Avg. Pages/Day")
                            }
                        }
                        .padding(20)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                    //.padding(.top, 12)
                    .padding(.horizontal)
                }
                .edgesIgnoringSafeArea([.horizontal, .bottom])
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)
    let context = container.mainContext
    
    // Create sample data
    let manager = ItemManager(modelContext: context)
    manager.addItem(name: "The Great Gatsby", numberOfPages: 100)
    manager.addItem(name: "1984", numberOfPages: 328)
    manager.addItem(name: "1Q84", numberOfPages: 450)
    
    return StatsViewModel(currentDate: .constant(Date()))
        .modelContainer(container)
}
