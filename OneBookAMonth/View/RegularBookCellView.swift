//
//  CustomCellView.swift
//  OneBookAMonth
//
//  Created by delightroom on 2/20/25.
//

import SwiftUI

struct RegularBookCellView: View {
    
    let item: Item
    @State private var dayTag: String = ""
    
    var body: some View {
        HStack {
            ZStack {
                CircularProgressView(progress: CGFloat(item.progress), bookImage: item.book_image)
                    .frame(width: 48, height: 48)
                Text("\(String(format: "%.0f", item.progress * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.8))
                    )
            }
            VStack {
                Text("\(item.name)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    //.padding(.bottom, 10)
                HStack {
                    Text(dayTag)
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                    Spacer()
                    ProgressTagView(progress: item.progress)
                }
//                Rectangle()
//                    .fill(Color.gray)
//                    .frame(height: 1)
//                    //.padding(.top, 10)
            }
            .padding(.horizontal, 8)
            
        }
        .padding(.vertical, 8)
        //.padding(.horizontal, 16)
        .onAppear {
            updateDayTag()
                }
        .refreshable {
            updateDayTag()
        }
    }
    
    private func updateDayTag() {
        let calendar = Calendar.current
        let startOfTimestamp = calendar.startOfDay(for: item.timestamp)
        var days: Int
        if let safeFinishedDate = item.finishedDate {
            let finishedDate = calendar.startOfDay(for: safeFinishedDate)
            days = calendar.dateComponents([.day], from: startOfTimestamp, to: finishedDate).day ?? 0
            dayTag = "Took \(abs(days)) days"
        } else {
            let startOfToday = calendar.startOfDay(for: Date())
            days = calendar.dateComponents([.day], from: startOfTimestamp, to: startOfToday).day ?? 0
            dayTag = "D+\(abs(days))"
        }
        
    }
    
}

#Preview {
    let dateFromString = Calendar.current.date(from: DateComponents(
        year: 2025,
        month: 2,
        day: 23
    ))
    
    let newItem = Item(timestamp: dateFromString ?? Date(), name: "StoryWorthyStoryWorthyStoryWorthy", numberOfPages: 450)
    RegularBookCellView(item: newItem)
}
