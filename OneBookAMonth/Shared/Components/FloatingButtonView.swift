//
//  FloatingButtonView.swift
//  OneBookAMonth
//
//  Created by delightroom on 3/29/25.
//

import SwiftUI
import SwiftData

struct FloatingButtonView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var showingAddDialog = false
    @Binding var needRefresh: UUID
    
    private var itemManager: ItemManager {
            ItemManager(modelContext: modelContext)
        }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Your main content here
            Color.clear
                .edgesIgnoringSafeArea(.all)
            
            // Floating button
            Button(action: {
                showingAddDialog = true
            }) {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.blue)
                    .cornerRadius(28)
                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
            }
            .padding(24)
        }
        .overlay {
            if showingAddDialog {
                ZStack {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingAddDialog = false
                        }
                    
                    AddItemViewModel(
                        isPresented: $showingAddDialog, needRefresh: $needRefresh
                    )
                }
            }
        }
    }
}

#Preview {
    FloatingButtonView(needRefresh: .constant(UUID()))
}
