//
//  BookCoverView.swift
//  OneBookAMonth
//
//  Created by delightroom on 8/16/25.
//

import SwiftUI

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
                    .fill(Color.gray.opacity(0.3))

                VStack(spacing: 4) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.8))

                }
            }
        }
    }
}

#Preview {
    BookCoverView(imageData: nil)
        .frame(width: 65, height: 90)
}