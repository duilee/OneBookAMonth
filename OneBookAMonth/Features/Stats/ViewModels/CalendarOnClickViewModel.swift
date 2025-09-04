//
//  CalendarOnClickViewModel.swift
//  OneBookAMonth
//
//  Created by delightroom on 4/12/25.
//

import SwiftUI
import SwiftData

struct CalendarOnClickViewModel: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    //@Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    @State private var swipeOffset: CGFloat = 0
    
    private var itemManager: ItemManager {
        ItemManager(modelContext: modelContext)
    }
    
    private func getNextDate() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    }
    
    private func getPreviousDate() -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func createDateView(for date: Date) -> some View {
        let formattedDate = formatDate(date)
        let stats = itemManager.getStats(for: items, period: TimePeriod.day, selectedDate: date)
        
        return ScrollView(.vertical) {
            VStack(spacing: 8) {
                Text("\(formattedDate)")
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                    .padding(.bottom, 8)
                VStack {
//                    Text("You Read")
//                        .font(.system(size: 16, weight: .bold))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.06))
                            .cornerRadius(16)
                        VStack {
                            HStack(spacing: 0) {
                                SmallStatItemView(value: "\(stats.totalPages)", label: "Pages")
                                SmallStatItemView(value: "\(stats.books)", label: "Books")
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                    }
                    
                    // Show page entries for the date
                    
                    
                    if let itemsForDate = try? itemManager.fetchItems(updatedOn: date) {
                        if !itemsForDate.isEmpty {
                            VStack(spacing: 16) {
                                
                                ForEach(itemsForDate) { item in
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.white)
                                            .cornerRadius(12)
                                        HStack(spacing: 8) {
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(item.name)
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .lineLimit(1)
                                                
                                                Text("\(item.getPagesReadForDate(date)) pages read")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.leading, 12)
                                            
                                            Spacer()
                                        }
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                        else {
                            Text("No readings for the day")
                                .font(.system(size: 16, weight: .semibold))
                                .lineLimit(1)
                                .padding(.top, 8)
                        }
                        
                    }
                }
                .padding(.horizontal, 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
    
    var body: some View {
        HStack {
            Button(action: {
                let dateRange = itemManager.getDateRange(for: items)
                let previousDate = getPreviousDate()
                if previousDate >= dateRange.start {
                    withAnimation(.default) {
                        swipeOffset = 300
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                            selectedDate = previousDate
                            swipeOffset = 0
                        }
                    }
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.white)
                    .padding(4)
                    .background(Color.clear)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            ZStack {
                // Previous date view
                if swipeOffset > 0 {
                    createDateView(for: getPreviousDate())
                        .offset(x: -300 + swipeOffset)
                        .transition(.opacity)
                }
                
                // Current date view
                createDateView(for: selectedDate)
                    .offset(x: swipeOffset)
                    .transition(.opacity)
                
                // Next date view
                if swipeOffset < 0 {
                    createDateView(for: getNextDate())
                        .offset(x: 300 + swipeOffset)
                        .transition(.opacity)
                }
            }
            .frame(width: 300, height: 200)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        swipeOffset = gesture.translation.width
                    }
                    .onEnded { gesture in
                        let dateRange = itemManager.getDateRange(for: items)
                        let velocity = gesture.predictedEndLocation.x - gesture.location.x
                        
                        withAnimation(.default) {
                            if gesture.translation.width > 50 || velocity > 300 {
                                // Swipe right - move to previous date
                                let previousDate = getPreviousDate()
                                if previousDate >= dateRange.start {
                                    swipeOffset = 300
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        selectedDate = previousDate
                                        swipeOffset = 0
                                    }
                                } else {
                                    swipeOffset = 0
                                }
                            } else if gesture.translation.width < -50 || velocity < -300 {
                                // Swipe left - move to next date
                                let nextDate = getNextDate()
                                if nextDate <= dateRange.end {
                                    swipeOffset = -300
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        selectedDate = nextDate
                                        swipeOffset = 0
                                    }
                                } else {
                                    swipeOffset = 0
                                }
                            } else {
                                swipeOffset = 0
                            }
                        }
                    }
            )
            Button(action: {
                let dateRange = itemManager.getDateRange(for: items)
                let nextDate = getNextDate()
                if nextDate <= dateRange.end {
                    withAnimation(.default) {
                        swipeOffset = -300
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                            selectedDate = nextDate
                            swipeOffset = 0
                        }
                    }
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.white)
                    .padding(4)
                    .background(Color.clear)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
    }
}

struct SmallStatItemView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CalendarOnClickViewModel(selectedDate: .constant(Date()))
}
