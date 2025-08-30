//
//  CircularProgressView.swift
//  OneBookAMonth
//
//  Created by delightroom on 3/31/25.
//

import SwiftUI

struct CircularProgressView: View {
  let progress: CGFloat
  let bookImage: Data?
  
  var body: some View {
    ZStack {
      // Book image if available
      if let imageData = bookImage, let uiImage = UIImage(data: imageData) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
          .clipShape(Circle())
      }
      
      // Background for the progress bar
      Circle()
        .stroke(lineWidth: 5)
        .opacity(0.1)
        .foregroundColor(.blue)

      // Foreground or the actual progress bar
      Circle()
        .trim(from: 0.0, to: min(progress, 1.0))
        .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
        .foregroundColor(.blue)
        .rotationEffect(Angle(degrees: 270.0))
        .animation(.linear, value: progress)
    }
  }
}

#Preview {
    CircularProgressView(progress: 0.7, bookImage: nil)
}
