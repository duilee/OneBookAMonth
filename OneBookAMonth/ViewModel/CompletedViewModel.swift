//
//  CompletedViewModel.swift
//  OneBookAMonth
//
//  Created by delightroom on 3/16/25.
//

import SwiftUI
import SwiftData

struct CompletedViewModel: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var selectedCompleteStatus: CompletedStatus = .ongoing
    // Computed property to get incomplete items
    private var targetItems: [Item] {
        if selectedCompleteStatus == .completed {
            return items.filter { $0.progress >= 1.0 }
        } else {
            return items.filter { $0.progress < 1.0 }
        }
    }
    
    private var itemManager: ItemManager {
            ItemManager(modelContext: modelContext)
        }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Books")
                        .font(.system(size: 28, weight: .bold))
                    
                    Spacer()
                }
                
                // Segmented Control
                Picker("Time Period", selection: $selectedCompleteStatus) {
                    ForEach(CompletedStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 8)
                
                
                
                List {
                    ForEach(targetItems) { item in
                        NavigationLink {
                            DetailViewModel(item: item)
                        } label: {
                            RegularBookCellView(item: item)
                            //TestCellView(item: item)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        withAnimation {
                            // Get the items to delete from the incompleteItems array
                            let itemsToDelete = offsets.map { targetItems[$0] }
                            
                            // Delete each item using the itemManager
                            for item in itemsToDelete {
                                itemManager.deleteItem(item)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
            }
            //.navigationBarTitle("1 Book a Month 📚")
            //.navigationBarTitleDisplayMode(.inline)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 10)
            .padding(.horizontal, 16)
            .edgesIgnoringSafeArea([.horizontal, .bottom])
        }
        .colorScheme(.light)
    }
}

#Preview {
    CompletedViewModel()
}
