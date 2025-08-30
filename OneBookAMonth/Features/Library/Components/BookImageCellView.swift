//
//  BookImageCellView.swift
//  OneBookAMonth
//
//  Created by delightroom on 8/2/25.
//

import SwiftUI

struct BookImageCellView: View {
    @Environment(\.modelContext) private var modelContext
    let item: Item
    @State private var dayTag: String = ""
    
    private var itemManager: ItemManager {
            ItemManager(modelContext: modelContext)
        }
    
    var body: some View {
        HStack {
            if let imageData = item.book_image, let uiImage = UIImage(data: imageData) {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 65 ,height: 75)
                        .cornerRadius(20)
                    VStack {
                        Text("\(String(format: "%.0f", item.progress * 100))%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.8))
                            )
                            .offset(y: 20)
                    }
                }
                    
            } else {
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
            }

            VStack(spacing: 0) {
                Text("\(item.name)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .padding(.bottom, 8)
                HStack {
                    // show "start reading 10 pages!" when progress == 0
                    HStack(spacing:6) {
                        let finishTimeline = itemManager.getFinishTimeline(item: item)
                    
                        Text("\(finishTimeline.pagesPerDay) pages")
                        
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                            .cornerRadius(12)
                        Text("x")
                            .font(.system(size: 15, weight: .semibold))
                            //.padding(.horizontal, 0)
                            //.padding(.vertical, 4)
                        Text("\(finishTimeline.daysLeft) days")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                            .cornerRadius(12)
                        Text("left!")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)// Add some internal padding
                    .background(Color.gray.opacity(0.1)) // Gray background
                    .cornerRadius(10) // Rounded corners
                    Spacer()
                }
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
    
    // Add sample book image for testing
    if let sampleImage = UIImage(systemName: "book.fill") {
        let imageData = sampleImage.pngData()
        newItem.book_image = imageData
    }
    
    return BookImageCellView(item: newItem)
}
