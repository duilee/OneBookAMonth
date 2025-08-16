//
//  HomeViewModel.swift
//  OneBookAMonth
//
//  Created by delightroom on 3/16/25.
//

import SwiftUI
import SwiftData
import HorizonCalendar

struct HomeViewModel: View {
    
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
    private var itemManager: ItemManager {
            ItemManager(modelContext: modelContext)
        }
    
    private let calendar = Calendar.current
    
    // Week heatmap data
    private var thisWeekDays: [ItemManager.WeekDayData] {
        itemManager.getThisWeekData(for: items, selectedDate: currentDate)
    }
    
    // Recent memos data
    private var recentMemos: [ItemManager.RecentMemoData] {
        itemManager.getRecentMemos(for: items)
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
                        // week, month, all stats view.
                        VStack {
                            
                            VStack(alignment: .leading, spacing: 12) {
                                
                                
                                // Segmented Control
                                Picker("Time Period", selection: $selectedPeriod) {
                                    ForEach(TimePeriod.mainCases, id: \.self) { period in
                                        Text(period.rawValue).tag(period)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.vertical, 4)
                                
                                // Stats View
                                let stats = itemManager.getStats(for: items, period: selectedPeriod, selectedDate: currentDate)
                                VStack(spacing: 20) {
                                    // Total Pages
                                    VStack(spacing: 4) {
                                        Text("\(stats.totalPages)")
                                            .font(.system(size: 40, weight: .bold))
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
                                .background(Color.gray.opacity(0.06))
                                .cornerRadius(16)
                            }
                            
                            // Chart View
                            let chartData = itemManager.getHistoricalReadingData(for: items, period: selectedPeriod)
                            ReadingChartView(data: chartData, period: selectedPeriod)
                                .padding(.bottom, 8)
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.06))
                                    .cornerRadius(16)
                                VStack(spacing: 12) {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 22, weight: .medium))
                                            .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                        Text("Daily Reading Calendar")
                                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.4)) {
                                                isCalendarExpanded.toggle()
                                            }
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }) {
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                                .rotationEffect(.degrees(isCalendarExpanded ? 180 : 0))
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.4)) {
                                            isCalendarExpanded.toggle()
                                        }
                                    }
                                    
                                    // Week heatmap when collapsed
                                    if !isCalendarExpanded {
                                        VStack(spacing: 8) {
                                            // Week label with stats
                                            HStack {
                                                Text("This Week")
                                                    .font(.caption.weight(.medium))
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.bottom, 8)
                                            
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
                                            let dateRange = itemManager.getDateRange(for: items)
                                            // Navigation buttons in top right
                                            HStack(spacing: 8) {
                                                Button(action: {
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
                                                        HStack {
                                                            Text("<")
                                                                .font(.system(size: 20, weight: .bold))
                                                                .foregroundColor(.black).opacity(0.7)
                                                                .padding(.leading, 8)
                                                        }
                                                    }
                                                }
                                                Button(action: {
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
                                                        HStack {
                                                            Text(">")
                                                                .font(.system(size: 20, weight: .bold))
                                                                .foregroundColor(.black).opacity(0.7)
                                                                .padding(.trailing, 8)
                                                        }
                                                    }
                                                }
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                            .padding(.top, 8)
                                            .padding(.trailing, 8)
                                            
                                            VStack {
                                                
                                                let dateActivityCounts = itemManager.getDateActivityCounts(for: items)
                                                
                                                
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
                            .padding(.bottom, 4)
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.06))
                                    .cornerRadius(16)
                                VStack(spacing: 12) {
                                    HStack {
                                        Image(systemName: "lightbulb")
                                            .font(.system(size: 22, weight: .medium))
                                            .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                        Text("Recent Memos")
                                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.4)) {
                                                isRecentMemosExpanded.toggle()
                                            }
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }) {
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                                .rotationEffect(.degrees(isRecentMemosExpanded ? 180 : 0))
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
                                                NavigationLink(destination: DetailViewModel(item: memoData.item)) {
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
                                            VStack(spacing: 8) {
                                                Image(systemName: "lightbulb")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                                
                                                Text("No recent memos")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.secondary)
                                                
                                                Text("Add memos to your books to see them here")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Color(UIColor.tertiaryLabel))
                                                    .multilineTextAlignment(.center)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.bottom, 12)
                                            .padding(.top, 12)
                                        }
                                    }
                                }
                                .padding(.vertical, 16)
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
    
    return HomeViewModel(selectedTab: .constant(1), currentDate: .constant(Date()))
            .modelContainer(container)
}
