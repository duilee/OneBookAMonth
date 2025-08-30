//
//  MemoView.swift
//  OneBookAMonth
//
//  Created by delightroom on 8/2/25.
//

import SwiftUI

struct MemoView: View {
    let memo: Memo
    var onImageTap: (() -> Void)? = nil
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    @State private var showFullScreenImage = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with date
            HStack {
                Image(systemName: "text.bubble.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
                
                Text(formatDate(memo.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatTime(memo.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if onEdit != nil {
                    Button(action: {
                        onEdit?()
                    }) {
                        Image(systemName: "pencil.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Image if available
            if let fullImage = memo.fullImage {
                Image(uiImage: fullImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 120)
                    .cornerRadius(12)
                    .clipped()
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture {
                        onImageTap?()
                    }
            }
            
            // Memo text
            Text(memo.text)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Delete button at bottom right
            if onDelete != nil {
                HStack {
                    Spacer()
                    Button(action: {
                        onDelete?()
                    }) {
                        Image(systemName: "trash.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    let sampleMemo = Memo(text: "This is a sample memo about the book. It contains some thoughts and reflections about what I've read so far. The characters are really interesting and the plot is engaging.")
    
    // Add sample image
    if let sampleImage = UIImage(systemName: "book.fill") {
        sampleMemo.setImage(sampleImage, itemID: UUID())
    }
    
    return VStack(spacing: 20) {
        MemoView(memo: sampleMemo)
            .padding()
        
        Spacer()
    }
    .background(Color.gray.opacity(0.1))
}
