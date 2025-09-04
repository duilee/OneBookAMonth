//
//  AddMemoView.swift
//  OneBookAMonth
//
//  Created by delightroom on 2/8/25.
//

import SwiftUI
import SwiftData

struct AddMemoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let item: Item
    let memo: Memo? // nil for add mode, non-nil for edit mode
    @Binding var isPresented: Bool
    
    // Core states
    @State private var memoText = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    // Edit mode flag
    private var isEditMode: Bool { memo != nil }
    
    // UI states
    @FocusState private var isTextEditorFocused: Bool
    @State private var showDiscardAlert = false
    @State private var isSaving = false
    
    private var itemManager: ItemManager {
        ItemManager(modelContext: modelContext)
    }
    
    // Validation
    private var canSave: Bool {
        !memoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var hasUnsavedChanges: Bool {
        !memoText.isEmpty || selectedImage != nil
    }
    
    // Smart placeholder based on reading progress
    private var placeholderText: String {
        switch item.progress {
        case 0.0...0.2:
            return "First impressions of this book..."
        case 0.2...0.5:
            return "What's happening in the story..."
        case 0.5...0.8:
            return "Thoughts on the plot so far..."
        case 0.8...1.0:
            return "Final thoughts and reflections..."
        default:
            return "Your thoughts about this book..."
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Photo Card Section
                    photoCardSection
                    
                    // Text Card Section
                    textCardSection
                    
                    // Text Metrics
                    textMetricsSection
                    
                    Spacer(minLength: 60) // Space for keyboard
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle(isEditMode ? "Edit Memo" : "Add Memo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        cancelMemo()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMemo()
                    }
                    .disabled(!canSave || isSaving)
                    .fontWeight(.semibold)
                }
                
                // Keyboard Done button for TextEditor
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isTextEditorFocused = false }
                }
            }
        }
        .alert("Discard Changes?", isPresented: $showDiscardAlert) {
            Button("Keep Editing", role: .cancel) { }
            Button("Discard", role: .destructive) {
                isPresented = false
            }
        } message: {
            Text("You have unsaved changes. Are you sure you want to discard them?")
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePickerView(
                image: $selectedImage,
                isPresented: $showImagePicker,
                compressionQuality: 0.8,
                targetHeight: 1920
            )
        }
        .onAppear {
            if let memo = memo {
                // Edit mode: load existing memo data
                memoText = memo.text
                selectedImage = memo.fullImage
            } else {
                // Add mode: load draft
                loadDraft()
            }
        }
    }
    
    // MARK: - Photo Card Section
    
    private var photoCardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "camera.fill")
                    .foregroundColor(.blue)
                Text("Photo")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            if let selectedImage = selectedImage {
                // Show captured image with retake option
                ZStack {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                    
                    // Overlay controls
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                showImagePicker = true
                            }) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            .padding(8)
                        }
                        Spacer()
                        HStack {
                            Button(action: {
                                self.selectedImage = nil
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "trash")
                                    Text("Remove")
                                }
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(16)
                            }
                            Spacer()
                        }
                        .padding(8)
                    }
                }
            } else {
                // Camera placeholder
                Button(action: {
                    showImagePicker = true
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                        
                        Text("Add Photo")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text("Capture a moment from your reading")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Text Card Section
    
    private var textCardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.bubble.fill")
                    .foregroundColor(.blue)
                Text("Your Memo")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $memoText)
                    .focused($isTextEditorFocused)
                    .frame(minHeight: 120)
                    .padding(12)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isTextEditorFocused ? Color.blue : Color.clear, lineWidth: 2)
                    )
                    .onChange(of: memoText) { _, _ in
                        if !isEditMode {
                            saveDraft()
                        }
                    }
                
                if memoText.isEmpty {
                    Text(placeholderText)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Text Metrics Section
    
    private var textMetricsSection: some View {
        HStack {
            Text("\(memoText.count) characters")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Actions
    
    private func saveMemo() {
        guard canSave else { return }
        
        isSaving = true
        
        let trimmedText = memoText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let memo = memo {
            // Edit mode: update existing memo
            itemManager.updateMemo(memo, text: trimmedText, image: selectedImage, itemID: item.id)
        } else {
            // Add mode: create new memo
            itemManager.addMemo(to: item, text: trimmedText, image: selectedImage)
        }
        
        // Clear draft only in add mode
        if !isEditMode {
            clearDraft()
        }
        
        isSaving = false
        isPresented = false
    }
    
    private func cancelMemo() {
        if hasUnsavedChanges {
            showDiscardAlert = true
        } else {
            clearDraft()
            isPresented = false
        }
    }
    
    // MARK: - Draft Management
    
    private func saveDraft() {
        UserDefaults.standard.set(memoText, forKey: "memo_draft_\(item.id)")
    }
    
    private func loadDraft() {
        let draftKey = "memo_draft_\(item.id)"
        if let draft = UserDefaults.standard.string(forKey: draftKey), !draft.isEmpty {
            memoText = draft
        }
    }
    
    private func clearDraft() {
        UserDefaults.standard.removeObject(forKey: "memo_draft_\(item.id)")
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, configurations: config)
    
    let sampleItem = Item(timestamp: Date(), name: "Sample Book", numberOfPages: 300)
    
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        AddMemoView(item: sampleItem, memo: nil, isPresented: .constant(true))
            .modelContainer(container)
    }
}
