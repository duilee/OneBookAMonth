//
//  StatsView.swift
//  OneBookAMonth
//
//  Created by delightroom on 3/16/25.
//

import SwiftUI
import SwiftData
import HorizonCalendar

struct StatsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    // Computed property to get incomplete items
    private var incompleteItems: [Item] {
        items.filter { $0.progress < 1.0 }
    }
        
//    @State private var showingAddDialog = false
    @Binding var selectedTab: Int
    @Binding var currentDate: Date
    @StateObject private var calendarViewProxy = CalendarViewProxy()
    // Add state to track data changes
    @State private var calendarRefreshTrigger = UUID()
    @State private var calendarDate = Date()
    @State private var selectedDate = Date()
    @State private var isCalendarDateSelected = false
    @State private var selectedPeriod: TimePeriod = .week
    @State private var isCalendarExpanded = false
    @State private var isRecentMemosExpanded = false
    
    // Store ItemManager as State to prevent recreating on every access
    @State private var itemManager: ItemManager?
    
    private let calendar = Calendar.current
    
    // Week heatmap data
    private var thisWeekDays: [ItemManager.WeekDayData] {
        itemManager?.getThisWeekData(for: items, selectedDate: currentDate) ?? []
    }
    
    // Recent memos data
    private var recentMemos: [ItemManager.RecentMemoData] {
        itemManager?.getRecentMemos(for: items) ?? []
    }
    
    // Helper computed properties for recent memos
    private var displayedMemos: [ItemManager.RecentMemoData] {
        if isRecentMemosExpanded {
            return Array(recentMemos.prefix(10))
        } else {
            return Array(recentMemos.prefix(1))
        }
    }
    
    var body: some View {
        NavigationView {
            //ZStack {
                
                VStack {
                    HStack {
                        Text("Stats")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.black)

                        Spacer()
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            // Progress Insights Section
                            VStack(alignment: .leading, spacing: 16) {
                                // Section Header
                                Label {
                                    HStack {
                                        Text("Progress")
                                            .font(.system(size: 20, weight: .semibold))
                                        Spacer()
                                    }
                                } icon: {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                }
                                .padding(.horizontal, 4)
                                
                                // Combined Stats + Chart Card
                                VStack(alignment: .leading, spacing: 16) {
                                    // Segmented Control
                                    Picker("Time Period", selection: $selectedPeriod) {
                                        ForEach(TimePeriod.mainCases, id: \.self) { period in
                                            Text(period.rawValue).tag(period)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    .padding(.vertical, 4)
                                    
                                    // Stats View
                                    let stats = itemManager?.getStats(for: items, period: selectedPeriod, selectedDate: currentDate) ?? (totalPages: 0, books: 0, daysRead: 0, avgPages: 0.0)
                                    VStack(spacing: 20) {
                                        // Total Pages
                                        VStack(spacing: 4) {
                                            Text("\(stats.totalPages)")
                                                .font(.system(size: 36, weight: .semibold))
                                                .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
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
                                    
                                    // Chart View (integrated)
                                    let chartData = itemManager?.getHistoricalReadingData(for: items, period: selectedPeriod) ?? []
                                    ReadingChartView(data: chartData, period: selectedPeriod)
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
                            }
                            
                            // Activity Tracking Section
                            VStack(alignment: .leading, spacing: 16) {
                                // Section Header
                                Label {
                                    HStack {
                                        Text("Activity Tracking")
                                            .font(.system(size: 20, weight: .semibold))
                                        Spacer()
                                    }
                                } icon: {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                }
                                .padding(.horizontal, 4)
                                
                                ZStack {
                                    Rectangle()
                                        .fill(Color.white)
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                                        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
                                    VStack(spacing: 6) {
                                        HStack {
                                        Text(isCalendarExpanded ? "Daily Reading" : "This Week")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.4)) {
                                                isCalendarExpanded.toggle()
                                            }
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }) {
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                                .rotationEffect(.degrees(isCalendarExpanded ? 180 : 0))
                                                .frame(width: 44, height: 44)
                                                .contentShape(Rectangle())
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    //.contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.4)) {
                                            isCalendarExpanded.toggle()
                                        }
                                    }
                                    
                                    // Week heatmap when collapsed
                                    if !isCalendarExpanded {
                                        VStack(spacing: 8) {
                                            
                                            // 7 squares for the week
                                            HStack(spacing: 4) {
                                                ForEach(thisWeekDays, id: \.date) { dayData in
                                                    VStack(spacing: 4) {
                                                        RoundedRectangle(cornerRadius: 4)
                                                            .fill(dayData.hasActivity ? 
                                                                  Color(red: 25/255, green: 45/255, blue: 155/255) :
                                                                  Color.gray.opacity(0.2))
                                                            .frame(width: 32, height: 32)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 4)
                                                                    .stroke(dayData.isToday ? Color.red : Color.clear, lineWidth: 2)
                                                            )
                                                            .overlay(
                                                                Text(dayData.dayLetter)
                                                                    .font(.system(size: 12, weight: .medium))
                                                                    .foregroundColor(dayData.hasActivity ? .white : .secondary)
                                                            )
                                                        
                                                        // Show pages count for active days
                                                        if dayData.hasActivity {
                                                            Text("\(dayData.pages)")
                                                                .font(.system(size: 10, weight: .medium))
                                                                .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                                        } else {
                                                            Text(" ")
                                                                .font(.system(size: 10))
                                                        }
                                                    }
                                                    .padding(.horizontal, 4)
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                        }
                                        //.padding(.bottom, 12)
                                    }
                                    
                                    if isCalendarExpanded {
                                        ZStack {
                                            let dateRange = itemManager?.getDateRange(for: items) ?? (start: Date(), end: Date())
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
                                                
                                                let dateActivityCounts = itemManager?.getDateActivityCounts(for: items) ?? [:]
                                                
                                                
                                                CalendarViewRepresentable(
                                                    calendar: calendar,
                                                    visibleDateRange: dateRange.start...dateRange.end,
                                                    monthsLayout: .horizontal(options: HorizontalMonthsLayoutOptions()),
                                                    dataDependency: calendarRefreshTrigger,
                                                    proxy: calendarViewProxy
                                                )
                                                .backgroundColor(.clear)
                                                .days { day in
                                                    VStack {
                                                        ZStack {
                                                            let date = getDate(from: day, from: calendar)
                                                            let count = dateActivityCounts[date] ?? 0
                                                            let color = getColor(for: count)
                                                            let isToday = calendar.isDate(date, inSameDayAs: currentDate)
                                                            
                                                            Circle()
                                                                .fill(count > 0 ?
                                                                      color.opacity(0.7)
                                                                      : Color.clear)
                                                                .overlay(
                                                                    Circle()
                                                                        .stroke(isToday ? Color.red : Color.clear, lineWidth: isToday ? 2 : 0)
                                                                )
                                                                .frame(width: 32, height: 32)
                                                            Text("\(day.day)")
                                                                .font(.system(size: 15, weight: .medium))
                                                                .foregroundColor(Color(UIColor.label))
                                                                .frame(maxWidth: 36, maxHeight: 36)
                                                        }
                                                        
                                                    }
                                                }
                                                .onDaySelection { day in
                                                    if let safeSelectedDate = calendar.date(from: day.components) {
                                                        selectedDate = safeSelectedDate
                                                    }
                                                    isCalendarDateSelected = true
                                                }
                                                .verticalDayMargin(-6)
                                                .horizontalDayMargin(0)
                                                .onAppear {
                                                    calendarViewProxy.scrollToMonth(containing: .now, scrollPosition: .centered, animated: false)
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.bottom, 12)
                                            .padding(.top, 32)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        }
                                        
                                    }
                                }
                                .padding(.vertical, 16)
                            }
                            }
                            
                            // Reading Insights Section
                            VStack(alignment: .leading, spacing: 16) {
                                // Section Header
                                Label {
                                    HStack {
                                        Text("Reading Insights")
                                            .font(.system(size: 20, weight: .semibold))
                                        Spacer()
                                    }
                                } icon: {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                }
                                .padding(.horizontal, 4)
                                
                                ZStack {
                                    Rectangle()
                                        .fill(Color.white)
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                                        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
                                    VStack(spacing: 12) {
                                        HStack {
                                            Text("Recent Memos")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.4)) {
                                                isRecentMemosExpanded.toggle()
                                            }
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }) {
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                                .rotationEffect(.degrees(isRecentMemosExpanded ? 180 : 0))
                                                .frame(width: 44, height: 44)
                                                .contentShape(Rectangle())
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.4)) {
                                            isRecentMemosExpanded.toggle()
                                        }
                                    }
                                    
                                    // Recent memos content
                                    if !recentMemos.isEmpty {
                                        VStack(spacing: 8) {
                                            ForEach(displayedMemos, id: \.memo.id) { memoData in
                                                NavigationLink(destination: BookDetailView(item: memoData.item)) {
                                                    RecentMemoCardView(
                                                        memoData: memoData,
                                                        isExpanded: isRecentMemosExpanded
                                                    )
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.bottom, 12)
                                    } else {
                                        if isRecentMemosExpanded {
                                            VStack(spacing: 16) {
                                                Image(systemName: "lightbulb.circle.fill")
                                                    .font(.system(size: 48))
                                                    .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255).opacity(0.3))
                                                    .symbolRenderingMode(.hierarchical)
                                                
                                                VStack(spacing: 8) {
                                                    Text("Your thoughts, captured")
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundColor(.primary)
                                                    
                                                    Text("Add memos while reading to build your\npersonal library of insights")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.secondary)
                                                        .multilineTextAlignment(.center)
                                                        .lineSpacing(2)
                                                }
                                            }
                                            .padding(.horizontal, 32)
                                            .padding(.vertical, 24)
                                        }
                                    }
                                }
                                .padding(.vertical, 16)
                            }
                            }
                            
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 60)
                    }
                }
                //FloatingButtonView(needRefresh: $calendarRefreshTrigger)
            //}
            .overlay {
                if isCalendarDateSelected {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                isCalendarDateSelected = false
                            }
                        
                        CalendarOnClickViewModel(selectedDate: $selectedDate)
                    }
                }
            }
        }
        .onAppear {
            // Initialize ItemManager once to prevent memory leak
            if itemManager == nil {
                itemManager = ItemManager(modelContext: modelContext)
            }
        }
        .colorScheme(.light)
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
//    if let randomItem = manager.fetchItems(updatedOn: Date()).randomElement() {
//        manager.updateProgress(randomItem, pages: 50, forDate: Date())
//    }
    
    return StatsView(selectedTab: .constant(1), currentDate: .constant(Date()))
            .modelContainer(container)
}
