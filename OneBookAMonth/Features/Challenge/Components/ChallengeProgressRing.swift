//
//  ChallengeProgressRing.swift
//  OneBookAMonth
//
//  Created by delightroom on 3/30/25.
//

import SwiftUI

struct ChallengeProgressRing: View {
    let progress: Double // 0.0 to 1.0
    let lineWidth: CGFloat
    let size: CGFloat
    
    init(progress: Double, lineWidth: CGFloat = 8, size: CGFloat = 120) {
        self.progress = max(0, min(1, progress)) // Clamp between 0 and 1
        self.lineWidth = lineWidth
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.1)
                .foregroundColor(ColorPalette().medium)
            
            // Progress ring
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .foregroundColor(progressColor)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            // Center content
            VStack(spacing: 4) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.2, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Complete")
                    .font(.system(size: size * 0.08, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
    
    private var progressColor: Color {
        switch progress {
        case 0.0..<0.25:
            return ColorPalette().light
        case 0.25..<0.5:
            return ColorPalette().medium
        case 0.5..<0.75:
            return ColorPalette().deep
        case 0.75..<1.0:
            return .green
        default:
            return .green
        }
    }
}

struct LargeChallengeProgressRing: View {
    let progress: Double
    let currentPages: Int
    let targetPages: Int
    let daysRemaining: Int
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(lineWidth: 12)
                .opacity(0.1)
                .foregroundColor(ColorPalette().medium)
            
            // Progress ring
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    style: StrokeStyle(
                        lineWidth: 12,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .foregroundColor(progressColor)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.easeInOut(duration: 1.5), value: progress)
            
            // Center content
            VStack(spacing: 6) {
                // Progress percentage
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                // Pages progress
                HStack(spacing: 4) {
                    Text("\(currentPages)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ColorPalette().deep)
                    
                    Text("/")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("\(targetPages)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Text("pages")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                // Days remaining (if not completed)
                if progress < 1.0 && daysRemaining > 0 {
                    Text("\(daysRemaining) days left")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(daysRemaining <= 7 ? .orange : .secondary)
                        .padding(.top, 2)
                } else if progress >= 1.0 {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        
                        Text("Completed!")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    .padding(.top, 2)
                }
            }
        }
        .frame(width: 180, height: 180)
    }
    
    private var progressColor: Color {
        switch progress {
        case 0.0..<0.25:
            return ColorPalette().light
        case 0.25..<0.5:
            return ColorPalette().medium
        case 0.5..<0.75:
            return ColorPalette().deep
        case 0.75..<1.0:
            return .green
        default:
            return .green
        }
    }
}

struct CompactChallengeProgressRing: View {
    let progress: Double
    let currentPages: Int
    let targetPages: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Small progress ring
            ZStack {
                Circle()
                    .stroke(lineWidth: 6)
                    .opacity(0.1)
                    .foregroundColor(ColorPalette().medium)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: 6,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .foregroundColor(progressColor)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.easeInOut(duration: 1.0), value: progress)
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
            }
            .frame(width: 60, height: 60)
            
            // Progress text
            VStack(alignment: .leading, spacing: 4) {
                Text("Progress")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Text("\(currentPages)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("/ \(targetPages)")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                
                Text("pages read")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var progressColor: Color {
        switch progress {
        case 0.0..<0.25:
            return ColorPalette().light
        case 0.25..<0.5:
            return ColorPalette().medium
        case 0.5..<0.75:
            return ColorPalette().deep
        case 0.75..<1.0:
            return .green
        default:
            return .green
        }
    }
}

#Preview("Standard Ring") {
    VStack(spacing: 30) {
        ChallengeProgressRing(progress: 0.3)
        ChallengeProgressRing(progress: 0.65)
        ChallengeProgressRing(progress: 0.9)
    }
    .padding()
}

#Preview("Large Ring") {
    VStack(spacing: 30) {
        LargeChallengeProgressRing(
            progress: 0.65,
            currentPages: 650,
            targetPages: 1000,
            daysRemaining: 12
        )
        
        LargeChallengeProgressRing(
            progress: 1.0,
            currentPages: 1000,
            targetPages: 1000,
            daysRemaining: 0
        )
    }
    .padding()
}

#Preview("Compact Ring") {
    VStack(spacing: 20) {
        CompactChallengeProgressRing(
            progress: 0.35,
            currentPages: 350,
            targetPages: 1000
        )
        
        CompactChallengeProgressRing(
            progress: 0.8,
            currentPages: 800,
            targetPages: 1000
        )
    }
    .padding()
}