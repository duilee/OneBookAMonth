//
//  TestCellView.swift
//  OneBookAMonth
//
//  Created by delightroom on 8/4/25.
//

import SwiftUI

// BookCoverView component
struct BookCoverView: View {
    let imageData: Data?

    var body: some View {
        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        } else {
            // Placeholder when no image
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(spacing: 4) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.8))

                    Text("No Cover")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
    }
}

// Progress Bar component
struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.2))

                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(progress))
            }
        }
    }
}

struct TestCellView: View {
    let item: Item
    @State private var averagePace: Double = 0
    @State private var dayTag: String = ""

    var body: some View {
        VStack(spacing: 0) {
            
            // Header with cover and title
            HStack(spacing: 12) {
                ZStack(alignment: .bottom) {
                    BookCoverView(imageData: item.book_image)
                        .frame(width: 65, height: 85)
                        .cornerRadius(8)
                    
                    // Day tag overlaid on book cover
                    Text(dayTag)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Color(red: 25/255, green: 45/255, blue: 155/255).opacity(0.9)
                        )
                        .cornerRadius(4)
                        .offset(y: 4)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.system(size: 17, weight: .semibold))
                        .lineLimit(1)

                    HStack(spacing: 16) {
                        // Reading pace
                        HStack(spacing: 4) {
                            Image(systemName: "speedometer")
                                .font(.system(size: 14))
                            Text("\(Int(averagePace)) pages/day")
                                .font(.system(size: 14, weight: .medium))
                                //.font(.caption2)
                        }

                        // Expected completion
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                            Text("Finish in 5 days")
                                .font(.system(size: 14, weight: .medium))
                                //.font(.caption)
                        }
                    }
                    .foregroundColor(.secondary)
                    
                    // Progress section
                    VStack(spacing: 8) {
                        // Visual progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.1))

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .blue.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * CGFloat(item.progress))
                            }
                        }
                        .frame(height: 8)

                        HStack {
                            Text("\(Int(item.progress * 100))% Complete")
                                .font(.system(size: 13, weight: .medium))

                            Spacer()

                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Update")
                                }
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(.trailing, 10)
                            }
                            
                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Image(systemName: "note.text")
                                    Text("Memo")
                                }
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.top, 8)
                    //.padding(.bottom, 12)
                }

                
            }
            .padding(12)

 
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
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
    TestCellView(item: newItem)
}
