//
//  RecentMemoCardView.swift
//  OneBookAMonth
//
//  Created by delightroom on 8/16/25.
//

import SwiftUI

struct RecentMemoCardView: View {
    let memoData: ItemManager.RecentMemoData
    let isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(memoData.item.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .padding(.top, 4)
            
            HStack {
                Spacer()
                Text(formatDate(memoData.date))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            // Image if available
            if let fullImage = memoData.memo.fullImage {
                Image(uiImage: fullImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxHeight: 80)
                    .cornerRadius(12)
                    .clipped()
                    .contentShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Text(memoData.text)
                .font(.system(size: 14))
                .foregroundColor(isExpanded ? .black : .secondary)
                .lineLimit(isExpanded ? nil : 1)
                .padding(.vertical, 4)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    let dateFromString = Calendar.current.date(from: DateComponents(
        year: 2025,
        month: 8,
        day: 15
    ))
    
    let item = Item(timestamp: dateFromString ?? Date(), name: "Sample Book", numberOfPages: 300)
    let memo = Memo(text: "This is a sample memo with some interesting thoughts about the book.")
    
    let memoData = ItemManager.RecentMemoData(
        memo: memo,
        item: item,
        coverImageData: nil,
        hasImage: false,
        text: memo.text,
        date: memo.date
    )
    
    RecentMemoCardView(
        memoData: memoData,
        isExpanded: false
    )
    .padding()
}
