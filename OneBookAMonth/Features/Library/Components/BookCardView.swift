//
//  BookCardView.swift
//  OneBookAMonth
//
//  Created by delightroom on 8/4/25.
//

import SwiftUI


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

struct BookCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    
    let item: Item
    var onMemoTap: (() -> Void)? = nil  // Optional callback for memo action
    var onUpdateTap: (() -> Void)? = nil  // Optional callback for update action
    
    @State private var dayTag: String = ""
    @State private var lastUpdateDate = Date()
    
    private let primaryColor = Color(red: 25/255, green: 45/255, blue: 155/255)
    
    // State for sheets - only keep update progress local if no callback provided
    @State private var showUpdateProgress = false
    @State private var selectedPage = 0
    
    // Store timeline data to avoid recreating ItemManager
    @State private var finishTimeline: (daysLeft: Int, pagesPerDay: Int)?

    var body: some View {
        VStack(spacing: 0) {
            
            // Header with cover and title
            HStack(spacing: 12) {
                ZStack(alignment: .bottom) {
                    BookCoverView(imageData: item.book_image)
                        .frame(width: 65, height: 90)
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    // Day tag overlaid on book cover
                    Text(dayTag)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(primaryColor)
                                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        )
                        .offset(y: 6)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(1)

                    HStack(spacing: 12) {
                        if item.progress >= 1.0 {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                Text("Done!")
                                    .font(.system(size: 14, weight: .medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                        } else {
                            if let timeline = finishTimeline {
                                // Expected Reading pace
                                HStack(spacing: 4) {
                                    Image(systemName: "speedometer")
                                        .font(.system(size: 14))
                                    Text("\(Int(timeline.pagesPerDay)) pages/day")
                                        .font(.system(size: 14, weight: .medium))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }

                                // Expected completion days
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 14))
                                    Text("Done in \(Int(timeline.daysLeft)) days")
                                        .font(.system(size: 14, weight: .medium))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                            }
                        }

                    }
                    .foregroundColor(.secondary)
                    
                    // Progress section
                    VStack(spacing: 8) {
                        // Visual progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.gray.opacity(0.15))

                                RoundedRectangle(cornerRadius: 3)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                primaryColor,
                                                primaryColor.opacity(0.8)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * CGFloat(item.progress))
                            }
                        }
                        .frame(height: 6)

                        HStack {
                            Text("\(Int(item.progress * 100))% Complete")
                                .font(.system(size: 13, weight: .medium))

                            Spacer()
                            
                            Text("Hold for actions")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                //.opacity(0.5)
                        }
                    }
                    .padding(.top, 8)
                    //.padding(.bottom, 12)
                }

                
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .onAppear {
            updateDayTag()
            updateFinishTimeline()
            lastUpdateDate = Date()
        }
        .onChange(of: item.currentPage) {
            updateDayTag()
            updateFinishTimeline()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                let now = Date()
                if !Calendar.current.isDate(lastUpdateDate, inSameDayAs: now) {
                    updateDayTag()
                    lastUpdateDate = now
                }
            }
        }
        // Only show sheet if no callback provided (for standalone use)
        // When used in LibraryView, the parent will handle presentation
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
    
    private func updateFinishTimeline() {
        // Only calculate timeline for ongoing books
        if item.progress >= 1.0 {
            finishTimeline = nil
        } else {
            let manager = ItemManager(modelContext: modelContext)
            finishTimeline = manager.getFinishTimeline(item: item)
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
    BookCardView(item: newItem)
}
