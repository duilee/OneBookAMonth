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
    private var itemManager: ItemManager {
            ItemManager(modelContext: modelContext)
        }
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationView {
            //ZStack {
                
                VStack {
                    HStack {
                        Text("Readings")
                            .font(.system(size: 28, weight: .bold))

                        Spacer()
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
                    ScrollView {
                        VStack {
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.06))
                                    .cornerRadius(16)
                                let stats = itemManager.getStats(for: items, period: TimePeriod.week, selectedDate: currentDate)
                                VStack {
                                    HStack {
                                        Text("This Week")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                        Spacer()
                                    }
                                    .padding(.bottom, 4)
                                    HStack(spacing: 0) {
                                        StatItemView(value: "\(stats.totalPages)", label: "Pages Read")
                                        StatItemView(value: "\(stats.books)", label: "Books")
                                        StatItemView(value: "\(stats.daysRead)", label: "Days Read")
                                    }
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                                
                            }
                            .padding(.bottom, 4)
                            
                            // suggest banner
                            let itemsWithProgress = incompleteItems.filter { $0.progress > 0 }
                            if let randomItem = itemsWithProgress.randomElement() {
                                NavigationLink(destination: DetailViewModel(item: randomItem)) {
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.blue.opacity(0.06))
                                            .cornerRadius(16)
                                        VStack(spacing: 0) {
                                            HStack {
                                                Text("Continue Reading")
                                                    .font(.system(size: 20, weight: .semibold))
                                                    .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                                Spacer()
                                            }
                                            .padding(.bottom, 8)
                                            BookImageCellView(item:randomItem)
                                        }
                                        .padding(.top, 16)
                                        .padding(.bottom, 8)
                                        .padding(.horizontal, 16)
                                    }
                                }
                                .foregroundColor(.primary)
                                
                                
                                
                            }
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.06))
                                    .cornerRadius(16)
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
                            .padding(.top, 4)
                            .padding(.bottom, 12)
                            
                            VStack {
                                HStack {
                                    Text("Did you read today?")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                                    Spacer()
                                }
                                
                                LazyVStack(spacing: 0) {
                                    ForEach(incompleteItems) { item in
                                        NavigationLink(destination: DetailViewModel(item: item)) {
                                            TriggerBookCellView(item: item)
                                                .padding(.horizontal, 4)
                                        }
                                        .foregroundColor(.primary)
                                    }
                                }
                            }
                            .padding(.leading, 12)
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
