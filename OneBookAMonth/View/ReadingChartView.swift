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
                            Text("\(point.pages)")
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
                .frame(height: 150)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.caption2)
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
            return "\(count) weeks"
        case .month, .all:
            return "\(count) months"
        case .day:
            return "Last 7 days"
        }
    }
}

#Preview {
    ReadingChartView(
        data: [
            ItemManager.ChartDataPoint(label: "Jan", date: Date(), pages: 250),
            ItemManager.ChartDataPoint(label: "Feb", date: Date(), pages: 180),
            ItemManager.ChartDataPoint(label: "Mar", date: Date(), pages: 320)
        ],
        period: .month
    )
}
