//
//  DetailView.swift
//  OneBookAMonth
//
//  Created by delightroom on 2/21/25.
//

import SwiftUI
import SwiftData
import HorizonCalendar

struct DetailViewModel: View {
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var calendarViewProxy = CalendarViewProxy()
    @State private var calendarRefreshTrigger = UUID()

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
    
    var body: some View {
        VStack {

            
            ScrollView {
                VStack {
                    HStack {
                        // Add the book image view at the bottom using the image from the item
                        if let imageData = item?.book_image, let uiImage = UIImage(data: imageData) {
                            ZStack {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60 ,height: 70)
                                    .cornerRadius(20)
                                
                                // Camera icon overlay
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
                                .offset(x: 25, y: 20)
                            }
                            .padding(.horizontal, 12)
                                
                        } else {
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 60, height: 70)
                                    .cornerRadius(20)
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                Image(systemName: "camera.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .background(Circle().fill(Color.blue).frame(width: 30, height: 30))
                                    .foregroundColor(.white)
                                    .offset(x: 25, y: 20)
                            }
                            .padding(.horizontal, 12)
                            .onTapGesture {
                                showImagePicker = true
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(item!.name)")
                                .font(.system(size: 21, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            ProgressTagView(progress: item!.progress)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Button(action: {
                            isEditingItem = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .imageScale(.medium)
                                .font(.title2)
                                .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 0)
                    // add tag (off to a great start! etc...), timeline proposal
                    
                    // Stats
                    VStack {
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.08))
                                .cornerRadius(16)
                            //.frame(height: 200)
                            VStack {
                                HStack {
                                    Text("Current Progress")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Spacer()
                                }
                                //.padding(.horizontal, 24)
                                HStack {
                                    Text("\(item!.currentPage) of \(item!.numberOfPages) pages")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(UIColor.label))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Spacer()
                                    
                                }
                                //.padding(.vertical, 4)
                                .padding(.top, 4)
                                .padding(.bottom, 8)
                                .padding(.leading, 4)
                                HStack {
                                    ThickerProgressView(progress: Double(item!.progress))
                                    Text("\(String(format: "%.0f", item!.progress * 100))%")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .font(.system(size: 16, weight: .bold))
                                        .padding(.leading, 4)
                                }
                                //.padding(.horizontal, 24)
                                ZStack {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.08))
                                        .cornerRadius(16)
                                    //.frame(height: 80)
                                    VStack {
                                        Text("Started Reading On")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.bottom, 1)
                                        
                                        HStack {
                                            let formattedDate = formatDate(item!.timestamp)
                                            Text("\(formattedDate)")
                                                .font(.system(size: 16, weight: .regular))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 4)
                                HStack {
                                    let readingStats = itemManager?.getAveragePagesPerDay(item!) ?? (average: 0.0, daysRead: 0)
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.08))
                                            .cornerRadius(16)
                                        //.frame(height: 80)
                                        VStack {
                                            Text("Days Read")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.bottom, 1)
                                            
                                            HStack {
                                                let daysString = readingStats.daysRead == 1 ? "Day" : "Days"
                                                Text("\(readingStats.daysRead) \(daysString)")
                                                    .font(.system(size: 16, weight: .regular))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 16)
                                    }
                                    .padding(.vertical, 4)
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.08))
                                            .cornerRadius(16)
                                        //.frame(height: 80)
                                        VStack {
                                            Text("Average Pace")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.bottom, 1)
                                            
                                            HStack {
                                                let pageString = readingStats.average <= 1 ? "Page" : "Pages"
                                                Text("\(String(format: "%.0f", readingStats.average)) \(pageString)")
                                                    .font(.system(size: 16, weight: .regular))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 16)
                                    }
                                    .padding(.vertical, 4)
                                }
                                HStack(spacing: 8) {
                                    Button(action: {
                                        selectedPage = item!.currentPage
                                        isUpdatingProgress = true
                                    }) {
                                        ZStack {
                                            Rectangle()
                                                .fill(Color.blue)
                                                .cornerRadius(12)
                                                .frame(height:44)
                                                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                                            
                                            Text("Update Progress")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    Button(action: {
                                        showAddMemo = true
                                    }) {
                                        ZStack {
                                            Rectangle()
                                                .fill(Color.blue)
                                                .cornerRadius(12)
                                                .frame(width: 120, height: 44)
                                                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                                            
                                            Text("Add Memo")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                        .padding(.bottom, 6)
                    }
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
                    
                    // Calendar
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.08))
                            .cornerRadius(16)
                        VStack {
                            let dateRange = itemManager?.getDateRange(for: [item!]) ?? (start: Date(), end: Date())
                            let pageEntries = itemManager?.getPageEntries(for: item!) ?? [:]
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
                        .padding(.horizontal, 20)
                        .padding(.bottom, 0)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 0)
                    .padding(.horizontal, 12)
                    
                    // Memo Section with LazyVStack
                    // add no memo case
                    let memos = itemManager?.getMemos(for: item!, sortedBy: .dateDescending) ?? []
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Memos")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                            Spacer()
                            Text("\(memos.count)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 16)
                        if !memos.isEmpty {
                            // Use LazyVStack for performance
                            LazyVStack(spacing: 12) {
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
                                        .padding(.horizontal, 12)
                                    } else {
                                        MemoView(memo: memo, onEdit: {
                                            memoToEdit = memo
                                            showEditMemo = true
                                        }, onDelete: {
                                            memoToDelete = memo
                                            showDeleteMemoConfirmation = true
                                        })
                                        .padding(.horizontal, 12)
                                    }
                                }
                            }
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                
                                VStack(spacing: 8) {
                                    Text("Capture your thoughts!")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Add notes about key insights, favorite quotes, or memorable moments from your reading")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                }
                            }
                            .padding(.vertical, 32)
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.top, 16)
                    
                    
                    
                    // Delete Button
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.6))
                                .cornerRadius(12)
                                .frame(height: 44)
                                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                            
                            Text("Delete Book")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 16)
                    }
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
                .presentationDetents([.height(320)])
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
    var height: CGFloat = 18
    var backgroundColor: Color = Color(.systemGray5)
    var foregroundColor: Color = .blue
    var width: CGFloat {
        UIScreen.main.bounds.width * 0.68
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background track
            Rectangle()
                .fill(backgroundColor)
                .frame(width: width,
                     height: height)
                .cornerRadius(4)
            
            // Foreground track (the actual progress)
            Rectangle()
                .fill(foregroundColor)
                .frame(width: max(CGFloat(progress) * width, 0), height: height)
                .cornerRadius(4)
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
    DetailViewModel(item: newItem)
}
