//
//  ChallengeProgressRing.swift
//  OneBookAMonth
//
//  Created by Claude on 2025-08-31.
//

import SwiftUI

struct ChallengeProgressRing: View {
    let progress: Double
    let pagesRead: Int
    let targetPages: Int
    let lineWidth: CGFloat
    let size: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    private let primaryColor = Color(red: 25/255, green: 45/255, blue: 155/255)
    
    init(progress: Double, pagesRead: Int, targetPages: Int, lineWidth: CGFloat = 20, size: CGFloat = 200) {
        self.progress = min(1.0, max(0, progress))
        self.pagesRead = pagesRead
        self.targetPages = targetPages
        self.lineWidth = lineWidth
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: lineWidth
                )
                .frame(width: size, height: size)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            primaryColor,
                            primaryColor.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(Angle(degrees: -90))
                //.animation(.spring(response: 0.8, dampingFraction: 0.7), value: animatedProgress)
            
            // Center content
            VStack(spacing: 4) {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(size: size * 0.2, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("\(pagesRead)")
                    .font(.system(size: size * 0.12, weight: .semibold))
                    .foregroundColor(primaryColor)
                
                Text("of \(targetPages) pages")
                    .font(.system(size: size * 0.06, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = newValue
            }
        }
    }
}

// Smaller version for cards
struct MiniProgressRing: View {
    let progress: Double
    let size: CGFloat
    
    private let primaryColor = Color(red: 25/255, green: 45/255, blue: 155/255)
    
    init(progress: Double, size: CGFloat = 50) {
        self.progress = min(1.0, max(0, progress))
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    primaryColor,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(Angle(degrees: -90))
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.3, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        ChallengeProgressRing(
            progress: 0.65,
            pagesRead: 195,
            targetPages: 300
        )
        
        HStack(spacing: 20) {
            MiniProgressRing(progress: 0.3)
            MiniProgressRing(progress: 0.6)
            MiniProgressRing(progress: 0.9)
        }
    }
    .padding()
}
