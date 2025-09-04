//
//  Item.swift
//  ABookAMonth
//
//  Created by delightroom on 1/30/25.
//

import Foundation
import SwiftData
import UIKit

@Model
final class Item {
    var id: UUID
    var timestamp: Date
    var finishedDate: Date?
    var name: String
    var numberOfPages: Int
    var currentPage: Int
    var book_image: Data?
    
    @Relationship(deleteRule: .cascade) var pageEntries: [PageEntry]
    @Relationship(deleteRule: .cascade) var memos: [Memo]
    
    var progress: Float {
        Float(currentPage) / Float(numberOfPages)
    }
    
    init(timestamp: Date, name: String, numberOfPages: Int) {
        self.id = UUID()
        self.timestamp = timestamp
        self.finishedDate = nil
        self.name = name
        self.numberOfPages = numberOfPages
        self.currentPage = 0
        self.book_image = nil
        
        // Initialize with first entry
        let initialEntry = PageEntry(date: timestamp, pages: 0, pagesRead: 0)
        self.pageEntries = [initialEntry]
        self.memos = []
    }
    
    // Helper method to add pages for today
    func addPagesForDate(_ date: Date, _ item: Item, pages: Int) {
        if let existingEntry = pageEntries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            let pagesRead = pages - item.currentPage
            existingEntry.pagesRead += pagesRead
            existingEntry.cumsumPages = pages
        } else {
            let pagesRead = pages - item.currentPage
            let newEntry = PageEntry(date: date, pages: pages, pagesRead: pagesRead)
            pageEntries.append(newEntry)
        }
    }
    
    // Helper method to get pages for a specific date
    func getPagesForDate(_ date: Date) -> Int {
        return pageEntries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })?.cumsumPages ?? 0
    }
    
    // Helper method to get pages for a specific date
    func getPagesReadForDate(_ date: Date) -> Int {
        return pageEntries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })?.pagesRead ?? 0
    }
}

// Add a separate model for page entries
@Model
final class PageEntry {
    var date: Date
    var cumsumPages: Int
    var pagesRead: Int
    
    init(date: Date, pages: Int, pagesRead: Int) {
        self.date = date
        self.cumsumPages = pages
        self.pagesRead = pagesRead
    }
}

// MARK: - Memo Model
@Model
final class Memo {
    var id: UUID
    var text: String
    var date: Date
    var imageFilename: String?
    var thumbnailData: Data?
    
    init(text: String, date: Date = Date()) {
        self.id = UUID()
        self.text = text
        self.date = date
        self.imageFilename = nil
        self.thumbnailData = nil
    }
    
    // MARK: - Computed Properties
    
    var thumbnail: UIImage? {
        guard let data = thumbnailData else { return nil }
        return UIImage(data: data)
    }
    
    var fullImage: UIImage? {
        guard let filename = imageFilename else { return nil }
        return MemoImageManager.shared.loadFullImage(filename: filename)
    }
    
    var hasImage: Bool {
        return imageFilename != nil
    }
    
    // MARK: - Image Management
    
    func setImage(_ image: UIImage, itemID: UUID) {
        // Save full image to file system
        self.imageFilename = MemoImageManager.shared.saveImage(image, for: id, in: itemID)
        
        // Create and store compressed thumbnail in database
        let thumbnail = image.resized(maxWidth: 150, maxHeight: 150)
        self.thumbnailData = thumbnail.jpegData(compressionQuality: 0.6)
    }
    
    func deleteImage() {
        if let filename = imageFilename {
            MemoImageManager.shared.deleteImage(filename: filename)
        }
        self.imageFilename = nil
        self.thumbnailData = nil
    }
}
