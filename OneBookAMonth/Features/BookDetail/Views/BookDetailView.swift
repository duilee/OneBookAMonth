//
//  BookDetailView.swift
//  OneBookAMonth
//
//  Created by delightroom on 2/21/25.
//

import SwiftUI
import SwiftData
import HorizonCalendar

struct BookDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var calendarViewProxy = CalendarViewProxy()
    @State private var calendarRefreshTrigger = UUID()
    @State private var calendarDate = Date()

    @State private var isUpdatingProgress = false
    @State private var selectedPage = 0
    @State private var isEditingItem = false
    @State private var refreshTrigger = UUID()
    @State private var showDeleteConfirmation = false
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showAddMemo = false
    @State private var selectedMemo: Memo?
    @State private var showFullScreenImage = false
    @State private var memoToEdit: Memo?
    @State private var showEditMemo = false
    @State private var memoToDelete: Memo?
    @State private var showDeleteMemoConfirmation = false
    
    // Store ItemManager as State to prevent recreating on every access
    @State private var itemManager: ItemManager?
    
    private let calendar = Calendar.current
    let item: Item?
    
    // MARK: - Spacing Constants (8pt Grid System)
    private let spacing = (
        xs: CGFloat(4),
        sm: CGFloat(8),
        md: CGFloat(16),
        lg: CGFloat(24),
        xl: CGFloat(32)
    )
    
    var body: some View {
        VStack {

            
            ScrollView {
                VStack {
                    // MARK: - Book Header Section
                    HStack(alignment: .center, spacing: spacing.md) {
                        // Enhanced book image (80x100)
                        if let imageData = item?.book_image, let uiImage = UIImage(data: imageData) {
                            ZStack {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 100)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                
                                // Camera icon overlay
                                Button(action: {
                                    showImagePicker = true
                                }) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                        .frame(width: 28, height: 28)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                                }
                                .offset(x: 30, y: 35)
                            }
                                
                        } else {
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 80, height: 100)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                    .foregroundColor(.gray.opacity(0.5))
                                Button(action: {
                                    showImagePicker = true
                                }) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                        .frame(width: 28, height: 28)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                                }
                                .offset(x: 30, y: 35)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: spacing.sm) {
                            Text("\(item!.name)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            ProgressTagView(progress: item!.progress)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Button(action: {
                            isEditingItem = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                        }
                    }
                    .padding(.horizontal, spacing.md)
                    .padding(.top, spacing.md)
                    .padding(.bottom, spacing.sm)
                    // add tag (off to a great start! etc...), timeline proposal
                    
                    // MARK: - Progress Card
                    VStack(spacing: spacing.md) {
                        // Clean white card for progress
                        VStack(spacing: spacing.md) {
                            HStack {
                                Text("Current Progress")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                Spacer()
                            }
                            
                            HStack {
                                Text("\(item!.currentPage) of \(item!.numberOfPages) pages")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            
                            // Enhanced progress bar
                            HStack(spacing: spacing.sm) {
                                ThickerProgressView(
                                    progress: Double(item!.progress),
                                    height: 24
                                )
                                Text("\(String(format: "%.0f", item!.progress * 100))%")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                            }
                            
                            // Expected timeline info - Daily reading goal
                            if item!.progress < 1.0 {
                                let timeline = itemManager?.getFinishTimeline(item: item!)
                                if let timeline = timeline {
                                    VStack(spacing: 8) {
                                        // Main goal statement
                                        HStack(spacing: 8) {
                                            Image(systemName: "target")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                            
                                            Text("Read \(timeline.pagesPerDay) pages daily")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.primary)
                                        }
                                        
                                        // Supporting context
                                        Text("\(timeline.daysLeft) days to finish")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue.opacity(0.08))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.blue.opacity(0.15), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            // Inline stats strip
                            let readingStats = itemManager?.getAveragePagesPerDay(item!) ?? (average: 0.0, daysRead: 0)
                            HStack(spacing: 16) {
                                Label {
                                    Text(formatShortDate(item!.timestamp))
                                        .font(.system(size: 12, weight: .medium))
                                } icon: {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 11))
                                }
                                .foregroundColor(.secondary)
                                
                                Text("•")
                                    .foregroundColor(.secondary.opacity(0.5))
                                
                                Label {
                                    Text("\(readingStats.daysRead) \(readingStats.daysRead == 1 ? "day" : "days")")
                                        .font(.system(size: 12, weight: .medium))
                                } icon: {
                                    Image(systemName: "checkmark.circle")
                                        .font(.system(size: 11))
                                }
                                .foregroundColor(.secondary)
                                
                                Text("•")
                                    .foregroundColor(.secondary.opacity(0.5))
                                
                                Label {
                                    Text("\(String(format: "%.0f", readingStats.average)) p/day")
                                        .font(.system(size: 12, weight: .medium))
                                } icon: {
                                    Image(systemName: "speedometer")
                                        .font(.system(size: 11))
                                }
                                .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(spacing.md)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                        
                        // Action buttons row
                        HStack(spacing: spacing.sm) {
                            // Update Progress button
                            Button(action: {
                                selectedPage = item!.currentPage
                                isUpdatingProgress = true
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: "book.pages.fill")
                                        .font(.system(size: 22))
                                    Text("Update")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(Color.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color(red: 25/255, green: 45/255, blue: 155/255))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Add Memo button
                            Button(action: {
                                showAddMemo = true
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: "note.text.badge.plus")
                                        .font(.system(size: 22))
                                    Text("Memo")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(Color.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color(red: 25/255, green: 45/255, blue: 155/255))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                    }
                    .padding(.horizontal, spacing.md)
                    .padding(.top, spacing.sm)
                    
                    // MARK: - Focus Timer Card
                    FocusTimerCard(item: item!)
                        .padding(.horizontal, spacing.md)
                        .padding(.top, spacing.sm)
                    
                    .sheet(isPresented: $isUpdatingProgress) {
                        NavigationView {
                            VStack {
                                Picker("Select Page", selection: $selectedPage) {
                                    ForEach(0...item!.numberOfPages, id: \.self) { page in
                                        Text("\(page)")
                                    }
                                }
                                .pickerStyle(.wheel)
                            }
                            .navigationTitle("Update Progress")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItemGroup(placement: .cancellationAction) {
                                    Button("Cancel") {
                                        isUpdatingProgress = false
                                    }
                                }
                                
                                ToolbarItemGroup(placement: .confirmationAction) {
                                    Button("Save") {
                                        itemManager?.updateProgress(item!, pages: selectedPage)
                                        calendarRefreshTrigger = UUID()
                                        isUpdatingProgress = false
                                    }
                                }
                            }
                        }
                        .presentationDetents([.height(250)])
                    }
                    
                    // MARK: - Calendar Section
                    VStack(spacing: 0) {
                        let dateRange = itemManager?.getDateRange(for: [item!]) ?? (start: Date(), end: Date())
                        let pageEntries = itemManager?.getPageEntries(for: item!) ?? [:]
                        
                        ZStack {
                            // Navigation buttons in top right
                            HStack(spacing: 8) {
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    // Scroll to previous month if within range
                                    if let previousMonth = calendar.date(byAdding: .month, value: -1, to: calendarDate),
                                       previousMonth >= dateRange.start {
                                        calendarDate = previousMonth
                                        calendarViewProxy.scrollToMonth(containing: previousMonth, scrollPosition: .centered, animated: true)
                                    }
                                }) {
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(width: 40, height: 28)
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                    }
                                }
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    // Scroll to next month if within range
                                    if let nextMonth = calendar.date(byAdding: .month, value: 1, to: calendarDate),
                                       nextMonth <= dateRange.end {
                                        calendarDate = nextMonth
                                        calendarViewProxy.scrollToMonth(containing: nextMonth, scrollPosition: .centered, animated: true)
                                    }
                                }) {
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(width: 40, height: 28)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(.top, 8)
                            .padding(.trailing, 8)
                            
                            VStack {
                            CalendarViewRepresentable(
                                calendar: calendar,
                                visibleDateRange: dateRange.start...dateRange.end,
                                monthsLayout: .horizontal(options: HorizontalMonthsLayoutOptions()),
                                dataDependency: calendarRefreshTrigger,
                                proxy: calendarViewProxy)
                            .backgroundColor(.clear)
                            .days { day in
                                VStack {
                                    ZStack {
                                        let date = getDate(from: day, from: calendar)
                                        let page = pageEntries[date] ?? -1
                                        let isToday = calendar.isDate(date, inSameDayAs: Date())
                                        
                                        Rectangle()
                                            .fill(page > -1 ? Color(UIColor.systemBlue).opacity(0.5) : Color.clear)
                                            .cornerRadius(12)
                                            .padding(1)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(isToday ? Color.red : Color.clear, lineWidth: isToday ? 2 : 0)
                                                    .padding(1)
                                            )
                                            .frame(width: 40, height: 42)
                                        Text(page > -1 ? "\(page)" : "")
                                            .frame(maxWidth: 40, maxHeight: 42, alignment: .bottom)
                                            .foregroundColor(Color(UIColor.label))
                                            .font(.system(size: 13, weight: .semibold))
                                            .padding(.bottom, 2)
                                        Text("\(day.day)")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Color(UIColor.label))
                                            .frame(maxWidth: 40, maxHeight: 42)
                                            .padding(.bottom, 4)
                                        
                                        
                                    }
                                }
                            }
                            .verticalDayMargin(-2)
                            .horizontalDayMargin(0)
                            
                            .onAppear {
                                calendarViewProxy.scrollToMonth(containing: .now, scrollPosition: .centered, animated: false)
                            }
                            }
                            .padding(spacing.md)
                            .padding(.top, 32)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    }
                    .padding(.horizontal, spacing.md)
                    .padding(.top, spacing.sm)
                    
                    // MARK: - Memo Section
                    let memos = itemManager?.getMemos(for: item!, sortedBy: .dateDescending) ?? []
                    
                    VStack(alignment: .leading, spacing: spacing.sm) {
                        HStack {
                            Text("Memos")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                            Spacer()
                            if memos.count > 0 {
                                Text("\(memos.count)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(.horizontal, spacing.sm)
                                    .padding(.vertical, spacing.xs)
                                    .background(Color.blue.opacity(0.15))
                                    .cornerRadius(12)
                            }
                            
                            // Add memo button
                            Button(action: {
                                showAddMemo = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                            }
                        }
                        .padding(.horizontal, spacing.md)
                        if !memos.isEmpty {
                            // Use LazyVStack for performance
                            LazyVStack(spacing: spacing.sm) {
                                ForEach(memos, id: \.id) { memo in
                                    if memo.hasImage {
                                        MemoView(memo: memo, onImageTap: {
                                            selectedMemo = memo
                                        }, onEdit: {
                                            memoToEdit = memo
                                            showEditMemo = true
                                        }, onDelete: {
                                            memoToDelete = memo
                                            showDeleteMemoConfirmation = true
                                        })
                                        .padding(.horizontal, spacing.md)
                                    } else {
                                        MemoView(memo: memo, onEdit: {
                                            memoToEdit = memo
                                            showEditMemo = true
                                        }, onDelete: {
                                            memoToDelete = memo
                                            showDeleteMemoConfirmation = true
                                        })
                                        .padding(.horizontal, spacing.md)
                                    }
                                }
                            }
                        } else {
                            // Empty state with improved spacing
                            VStack(spacing: spacing.md) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255).opacity(0.8))
                                
                                VStack(spacing: spacing.sm) {
                                    Text("Capture your thoughts!")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Add notes about key insights, favorite quotes, or memorable moments from your reading")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, spacing.lg)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, spacing.xl + spacing.md)
                            .padding(.horizontal, spacing.md)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(16)
                            .padding(.horizontal, spacing.md)
                        }
                    }
                    .padding(.top, spacing.md)
                    // Delete button moved to EditItemViewModel
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.bottom, 60)
                .edgesIgnoringSafeArea([.horizontal, .bottom])
            }
            
        }
        .onAppear {
            // Initialize ItemManager once to prevent memory leak
            if itemManager == nil {
                itemManager = ItemManager(modelContext: modelContext)
            }
        }
        .sheet(isPresented: $isEditingItem) {
            EditItemViewModel(item: item!, isPresented: $isEditingItem)
                .presentationDetents([.height(380)])
                .presentationDragIndicator(.visible)
        }

        // Use fullScreenCover to present ImagePicker
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: loadImage) {
            ImagePickerView(image: $inputImage, isPresented: $showImagePicker, compressionQuality: 0.5, targetHeight: 100)
                .background(Color.white)
                .edgesIgnoringSafeArea(.bottom)
        }
        
        // Full screen image viewer for memo images
        .fullScreenCover(isPresented: $showFullScreenImage) {
            if let memo = selectedMemo, let fullImage = memo.fullImage {
                FullScreenImageView(image: fullImage, isPresented: $showFullScreenImage)
                    .onAppear {
                        print("FullScreen appeared with memo: \(memo.id)")
                    }
                    .onDisappear {
                        print("FullScreen disappeared")
                        // Clear all state when dismissed
                        selectedMemo = nil
                    }
            } else {
                //showFullScreenImage = false
                Text("No image selected")
            }
        }
        .overlay {
            if showDeleteConfirmation {
                ZStack {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showDeleteConfirmation = false
                        }
                    
                    DeleteConfirmationViewModel(
                        isPresented: $showDeleteConfirmation,
                        itemName: item!.name,
                        onConfirm: {
                            itemManager?.deleteItem(item!)
                        }
                    )
                }
            }
        }
        .overlay {
            if showAddMemo {
                ZStack {
                    // Dimmed background
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showAddMemo = false
                        }
                    
                    // Bottom sheet container
                    VStack {
                        Spacer()
         
                        // AddMemoView as bottom sheet
                        AddMemoView(item: item!, memo: nil, isPresented: $showAddMemo)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -5)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .frame(height: 570)
                            .offset(y: 30)
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }
                .animation(.easeInOut(duration: 0.3), value: showAddMemo)
            }
        }
        // Update onChange to use the zero-parameter closure
        .onChange(of: showImagePicker) {
            if !showImagePicker {
                loadImage()
            }
        }
        .onChange(of: selectedMemo) {
            if selectedMemo != nil {
                showFullScreenImage = true
            }
        }
        .onChange(of: showEditMemo) {
            if !showEditMemo {
                memoToEdit = nil
            }
        }
        .overlay {
            if showEditMemo {
                ZStack {
                    // Dimmed background
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showEditMemo = false
                        }
                    
                    // Bottom sheet container
                    VStack {
                        Spacer()
         
                        // AddMemoView as bottom sheet for editing
                        if let memoToEdit = memoToEdit {
                            AddMemoView(item: item!, memo: memoToEdit, isPresented: $showEditMemo)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: -5)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .frame(height: 570)
                                .offset(y: 30)
                        }
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }
                .animation(.easeInOut(duration: 0.3), value: showEditMemo)
            }
        }
        .alert("Delete Memo?", isPresented: $showDeleteMemoConfirmation) {
            Button("Cancel", role: .cancel) {
                memoToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let memo = memoToDelete {
                    itemManager?.deleteMemo(memo, from: item!)
                    memoToDelete = nil
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }

    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        if let item = item {
            itemManager?.saveBookImage(for: item, image: inputImage)
        }
    }
    
    func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMM d"
        return formatter.string(from: date)
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

struct ThickerProgressView: View {
    var progress: Double
    var height: CGFloat = 24
    var backgroundColor: Color = Color(.systemGray5)
    var foregroundColor: Color = .blue
    var width: CGFloat {
        UIScreen.main.bounds.width * 0.7
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background track
            RoundedRectangle(cornerRadius: height / 2)
                .fill(backgroundColor)
                .frame(width: width, height: height)
            
            // Foreground track (the actual progress)
            RoundedRectangle(cornerRadius: height / 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            foregroundColor,
                            foregroundColor.opacity(0.85)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: max(CGFloat(progress) * width, 0), height: height)
        }
        .frame(width: width) // Set desired width
    }
}

#Preview {
    let dateFromString = Calendar.current.date(from: DateComponents(
        year: 2025,
        month: 3,
        day: 10
    ))
    
    let newItem = Item(timestamp: dateFromString ?? Date(), name: "Story Worthy", numberOfPages: 450)
    BookDetailView(item: newItem)
}
