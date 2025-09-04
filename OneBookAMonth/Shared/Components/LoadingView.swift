//
//  LoadingView.swift
//  OneBookAMonth
//
//  Created by delightroom on 2/23/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var bookOffset: CGFloat = 0
    @State private var dotScale: [CGFloat] = [1, 1, 1]
    
    let coralColor = Color(red: 1.0, green: 0.42, blue: 0.42) // #FF6B6B
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Animated book emoji
                Text("📚")
                    .font(.system(size: 80))
                    .offset(y: bookOffset)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                        ) {
                            bookOffset = -20
                        }
                    }
                
                // App title
                Text("One Book a Month")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Loading dots
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color(UIColor.systemBlue).opacity(1))
                            .frame(width: 12, height: 12)
                            .scaleEffect(dotScale[index])
                            .onAppear {
                                withAnimation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(0.2 * Double(index))
                                ) {
                                    dotScale[index] = 1.5
                                }
                            }
                    }
                }
                
                // Loading text
                Text("Opening your reading journey...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}


#Preview {
    LoadingView()
}
