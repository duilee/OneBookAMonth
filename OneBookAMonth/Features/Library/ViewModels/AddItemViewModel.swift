//
//  SwiftUIView.swift
//  ABookAMonth
//
//  Created by delightroom on 2/15/25.
//

import SwiftUI
import SwiftData

struct AddItemViewModel: View {
    @Environment(\.modelContext) private var modelContext
    //@Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    @Binding var needRefresh: UUID
    
    @State private var itemName: String = ""
    @State private var totalCount: String = ""
    @State private var showError = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    
    private var itemManager: ItemManager {
        ItemManager(modelContext: modelContext)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add New Book")
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
            
            // Book image section
            VStack(spacing: 8) {
                Text("Book Cover (Optional)")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
                
                if let selectedImage = selectedImage {
                    ZStack {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        // Camera icon overlay (same pattern as BookDetailView)
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        .offset(x: 28, y: 38)
                    }
                } else {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 80, height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            
                            VStack(spacing: 4) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                                Text("Add Photo")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
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
            
            // Add button
            Button(action: addItem) {
                Text("Add Book")
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
            .padding(.bottom, 20)
        }
        .frame(width: 320, height: 460)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .alert("Invalid Input", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter a valid number")
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePickerView(image: $selectedImage, isPresented: $showImagePicker, compressionQuality: 0.5, targetHeight: 100)
                .background(Color.white)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    private func addItem() {
        guard let count = Int(totalCount) else {
            showError = true
            return
        }
        
        // Use the new addItem method that handles image
        itemManager.addItem(name: itemName, numberOfPages: count, image: selectedImage)
        
        isPresented = false
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)
    
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        AddItemViewModel(isPresented: .constant(true), needRefresh: .constant(UUID()))
            .modelContainer(container)
    }
}

