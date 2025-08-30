//
//  EditItemViewModel.swift
//  OneBookAMonth
//
//  Created by delightroom on 2/21/25.
//

import SwiftUI
import SwiftData

struct EditItemViewModel: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    
    let item: Item
    @State private var itemName: String
    @State private var totalCount: String
    @State private var showError = false
    @State private var showDeleteConfirmation = false
    
    private var itemManager: ItemManager {
        ItemManager(modelContext: modelContext)
    }
    
    init(item: Item, isPresented: Binding<Bool>) {
        self.item = item
        self._isPresented = isPresented
        self._itemName = State(initialValue: item.name)
        self._totalCount = State(initialValue: String(item.numberOfPages))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Edit Book")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                
                Spacer()
                
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(UIColor.systemGray))
                }
            }
            .padding(.top, 12)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            
            // Form fields
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Book Name")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                    
                    TextField("Enter book name", text: $itemName)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Pages")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                    
                    TextField("Enter total pages", text: $totalCount)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .onChange(of: totalCount) { oldValue, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue {
                                totalCount = filtered
                            }
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
            
            // Save button
            Button(action: saveChanges) {
                Text("Save Changes")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        itemName.isEmpty || totalCount.isEmpty
                        ? Color.gray
                        : Color(red: 25/255, green: 45/255, blue: 155/255)
                    )
                    .cornerRadius(12)
            }
            .disabled(itemName.isEmpty || totalCount.isEmpty)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            // Delete button
            Button(action: {
                showDeleteConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                    Text("Delete Book")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color(uiColor: .systemBackground))
        .alert("Invalid Input", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter a valid number")
        }
        .alert("Delete Book?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteBook()
            }
        } message: {
            Text("Are you sure you want to delete \"\(item.name)\"? This action cannot be undone.")
        }
    }
    
    private func saveChanges() {
        guard let count = Int(totalCount) else {
            showError = true
            return
        }
        
        itemManager.editItem(item, name: itemName, numberOfPages: count)
        isPresented = false
    }
    
    private func deleteBook() {
        itemManager.deleteItem(item)
        isPresented = false
        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)
    
    // Add sample data
    let dateFromString = Calendar.current.date(from: DateComponents(
        year: 2025,
        month: 3,
        day: 10
    ))
    let sampleItem = Item(timestamp: dateFromString ?? Date(), name: "Sample Book", numberOfPages: 300)
    
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        EditItemViewModel(item: sampleItem, isPresented: .constant(true))
            .modelContainer(container)
    }
} 
