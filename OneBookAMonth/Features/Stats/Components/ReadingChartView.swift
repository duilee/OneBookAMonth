//
//  ReadingChartView.swift
//  OneBookAMonth
//
//  Created by delightroom on 8/16/25.
//

import SwiftUI
import Charts

struct ReadingChartView: View {
    let data: [ItemManager.ChartDataPoint]
    let period: TimePeriod
    @State private var selectedLabel: String? = nil
    
    private var maxPages: Int {
        data.map { $0.pages }.max() ?? 0
    }
    
    // MARK: - Label Configuration
    private var visibleLabelIndices: Set<Int> {
        let count = data.count
        guard count > 6 else {
            return Set(0..<count)
        }
        
        // Always include first and last
        var indices: Set<Int> = [0]
        var indiceToAdd: Int = 0
        
        
        // Add 6 more evenly distributed points
        let step = Int(Double(count) / 5.0) + 1
        for i in 1..<6 {
            indiceToAdd = Int(i * step)
            if indiceToAdd <= count - 1 {
                indices.insert(indiceToAdd)
            }
            
        }
        
        return indices
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Reading History")
                    .font(.headline)
                Spacer()
                Text(periodDescription)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if data.isEmpty {
                Text("Start reading to see your progress chart!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Chart(data) { point in
                            BarMark(
                                x: .value("Period", point.label),
                                y: .value("Pages", point.pages)
                            )
                            .foregroundStyle(
                                selectedLabel == point.label ?
                                // Highlighted selected bar
                                LinearGradient(
                                    colors: [Color(red: 25/255, green: 45/255, blue: 155/255).opacity(0.7), Color(red: 25/255, green: 45/255, blue: 155/255).opacity(0.9)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                                :
                                // Normal blue bars
                                LinearGradient(
                                    colors: [Color(red: 25/255, green: 45/255, blue: 155/255), Color(red: 25/255, green: 45/255, blue: 155/255)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .cornerRadius(4)
                            .annotation(position: .top) {
                                if selectedLabel == point.label {
                                    VStack {
                                        Text("\(point.label):\n\(point.pages)")
                                            .font(.caption.bold())
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.black.opacity(0.8))
                                            .foregroundColor(.white)
                                            .cornerRadius(4)
                                            .offset(y: -4)
                                    }
                                }
                            }
                        }
                        .frame(height: 150)
                        .padding(.top, 15)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .chartXAxis {
                            AxisMarks { value in
                                if let label = value.as(String.self),
                                   let index = data.firstIndex(where: { $0.label == label }),
                                   visibleLabelIndices.contains(index) {
                                    AxisValueLabel {
                                        Text(label)
                                            .font(.caption2)
                                            .lineLimit(1)
                                            .fixedSize()
                                    }
                                }
                            }
                        }
                        .chartYScale(domain: 0...max(maxPages, 100))
                        .chartOverlay { proxy in
                            GeometryReader { geometry in
                                Rectangle()
                                    .fill(Color.clear)
                                    .contentShape(Rectangle())
                                    .onTapGesture { location in
                                        let plotFrame = geometry[proxy.plotAreaFrame]
                                        let xPosition = location.x - plotFrame.origin.x
                                        let barWidth = plotFrame.width / CGFloat(data.count)
                                        let index = Int(xPosition / barWidth)
                                        
                                        if index >= 0 && index < data.count {
                                            let tappedLabel = data[index].label
                                            selectedLabel = selectedLabel == tappedLabel ? nil : tappedLabel
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                    }
                            }
                        }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.06))
        .cornerRadius(16)
    }
    
    private var periodDescription: String {
        let count = data.count
        switch period {
        case .week:
            return "Recent \(count) weeks"
        case .month, .all:
            return "Recent \(count) months"
        case .day:
            return "Last 7 days"
        }
    }
}

#Preview("Few Labels") {
    ReadingChartView(
        data: [
            ItemManager.ChartDataPoint(label: "Jan", date: Date(), pages: 250),
            ItemManager.ChartDataPoint(label: "Feb", date: Date(), pages: 180),
            ItemManager.ChartDataPoint(label: "Mar", date: Date(), pages: 320)
        ],
        period: .month
    )
}

#Preview("Many Labels (12 months)") {
    ReadingChartView(
        data: [
            ItemManager.ChartDataPoint(label: "Jan", date: Date(), pages: 250),
            ItemManager.ChartDataPoint(label: "Feb", date: Date(), pages: 180),
            ItemManager.ChartDataPoint(label: "Mar", date: Date(), pages: 320),
            ItemManager.ChartDataPoint(label: "Apr", date: Date(), pages: 290),
            ItemManager.ChartDataPoint(label: "May", date: Date(), pages: 310),
            ItemManager.ChartDataPoint(label: "Jun", date: Date(), pages: 275),
            ItemManager.ChartDataPoint(label: "Jul", date: Date(), pages: 340),
            ItemManager.ChartDataPoint(label: "Aug", date: Date(), pages: 280),
            ItemManager.ChartDataPoint(label: "Sep", date: Date(), pages: 320),
            ItemManager.ChartDataPoint(label: "Oct", date: Date(), pages: 290),
            ItemManager.ChartDataPoint(label: "Nov", date: Date(), pages: 310),
            ItemManager.ChartDataPoint(label: "Dec", date: Date(), pages: 350)
        ],
        period: .month
    )
}

#Preview("Rotation Threshold (6 labels)") {
    ReadingChartView(
        data: [
            ItemManager.ChartDataPoint(label: "Jan", date: Date(), pages: 250),
            ItemManager.ChartDataPoint(label: "Feb", date: Date(), pages: 180),
            ItemManager.ChartDataPoint(label: "Mar", date: Date(), pages: 320),
            ItemManager.ChartDataPoint(label: "Apr", date: Date(), pages: 290),
            ItemManager.ChartDataPoint(label: "May", date: Date(), pages: 310),
            ItemManager.ChartDataPoint(label: "Jun", date: Date(), pages: 275)
        ],
        period: .month
    )
}
