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
    
    // State for managing memo and update presentations
    @State private var showAddMemo = false
    @State private var showUpdateProgress = false
    @State private var selectedItemForMemo: Item?
    @State private var selectedItemForUpdate: Item?
    @State private var selectedPage = 0
    
    // State for adding new books
    @State private var showAddItem = false
    @State private var refreshTrigger = UUID()
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
                    Text("Readings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.black)
                    
                    Spacer()
                    
                    Button(action: {
                        showAddItem = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
                
                // Custom Tab Buttons (style similar to the image)
                HStack(spacing: 4) {
                    ForEach(CompletedStatus.allCases, id: \.self) { status in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedCompleteStatus = status
                            }
                        }) {
                            Text(status.rawValue)
                                .font(.system(size: 15, weight: selectedCompleteStatus == status ? .semibold : .medium))
                                .foregroundColor(selectedCompleteStatus == status ? .white : .secondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                //.frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(selectedCompleteStatus == status ? Color(red: 25/255, green: 45/255, blue: 155/255) : Color.gray.opacity(0.1))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 4)
                .padding(.top, 8)
                .padding(.bottom, 8)
//                .background(
//                    RoundedRectangle(cornerRadius: 24)
//                        .fill(Color.gray.opacity(0.1))
//                )
                
                
                // ScrollView with LazyVStack instead of List
                if targetItems.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        //Spacer()
                        Image(systemName: selectedCompleteStatus == .completed ? "checkmark.circle" : "book.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text(selectedCompleteStatus == .completed ? "No completed books yet" : "No books in progress")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(selectedCompleteStatus == .completed ? "Books you finish will appear here" : "Start reading a book to see it here")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 60)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(targetItems) { item in
                                NavigationLink(destination: DetailViewModel(item: item)) {
                                    BookCardView(
                                        item: item,
                                        onMemoTap: {
                                            selectedItemForMemo = item
                                        },
                                        onUpdateTap: {
                                            selectedItemForUpdate = item
                                            selectedPage = item.currentPage
                                        }
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.vertical, 4)
                                .contextMenu {
                                    Button {
                                        selectedItemForUpdate = item
                                        selectedPage = item.currentPage
                                        showUpdateProgress = true
                                    } label: {
                                        Label("Update Progress", systemImage: "book.pages")
                                    }
                                    
                                    Button {
                                        selectedItemForMemo = item
                                        showAddMemo = true
                                    } label: {
                                        Label("Add Memo", systemImage: "note.text")
                                    }
                                    
                                    Divider()
                                    
                                    // Quick actions
                                    Button {
                                        let newPage = min(item.currentPage + 10, item.numberOfPages)
                                        itemManager.updateProgress(item, pages: newPage)
                                    } label: {
                                        Label("Quick +10 pages", systemImage: "plus.circle")
                                    }
                                    
                                    Button {
                                        let newPage = min(item.currentPage + 25, item.numberOfPages)
                                        itemManager.updateProgress(item, pages: newPage)
                                    } label: {
                                        Label("Quick +25 pages", systemImage: "plus.circle.fill")
                                    }
                                    
                                    if item.progress < 1.0 {
                                        Divider()
                                        
                                        Button {
                                            itemManager.updateProgress(item, pages: item.numberOfPages)
                                        } label: {
                                            Label("Mark as Finished", systemImage: "checkmark.circle.fill")
                                        }
                                        .tint(.green)
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 60)
                    }
                    .refreshable {
                        // Optional: Add refresh functionality if needed
                    }
                }
            }
            //.navigationBarTitle("1 Book a Month 📚")
            //.navigationBarTitleDisplayMode(.inline)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 10)
            .padding(.horizontal, 16)
        }
        .colorScheme(.light)
        // Sheet for update progress
        .onChange(of: selectedItemForUpdate) {
            if selectedItemForUpdate != nil {
                showUpdateProgress = true
            }
        }
        .onChange(of: selectedItemForMemo) {
            if selectedItemForMemo != nil {
                showAddMemo = true
            }
        }
        .sheet(isPresented: $showUpdateProgress) {
            if let item = selectedItemForUpdate {
                NavigationView {
                    VStack {
                        Picker("Select Page", selection: $selectedPage) {
                            ForEach(0...item.numberOfPages, id: \.self) { page in
                                Text("\(page)")
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .navigationTitle("Update Progress")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showUpdateProgress = false
                                selectedItemForUpdate = nil
                            }
                        }
                        
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                itemManager.updateProgress(item, pages: selectedPage)
                                showUpdateProgress = false
                                selectedItemForUpdate = nil
                            }
                        }
                    }
                }
                .presentationDetents([.height(250)])
            }
        }
        // Overlay for AddMemoView - full screen coverage
        .overlay {
            if showAddMemo, let item = selectedItemForMemo {
                ZStack {
                    // Dimmed background
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showAddMemo = false
                            selectedItemForMemo = nil
                        }
                    
                    // Bottom sheet container
                    VStack {
                        Spacer()
         
                        // AddMemoView as bottom sheet
                        AddMemoView(item: item, memo: nil, isPresented: $showAddMemo)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -5)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .frame(height: 570)
                            .offset(y: 30)
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }
                .animation(.easeInOut(duration: 0.3), value: showAddMemo)
                .onDisappear {
                    selectedItemForMemo = nil
                }
            }
        }
        // Overlay for AddItemViewModel
        .overlay {
            if showAddItem {
                ZStack {
                    // Dimmed background
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showAddItem = false
                        }
                    
                    // AddItemViewModel centered
                    AddItemViewModel(isPresented: $showAddItem, needRefresh: $refreshTrigger)
                }
                .animation(.easeInOut(duration: 0.3), value: showAddItem)
            }
        }
    }
}

#Preview {
    CompletedViewModel()
}
