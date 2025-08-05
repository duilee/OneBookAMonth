//
//  MemoImageManager.swift
//  OneBookAMonth
//
//  Created by delightroom on 2/8/25.
//

import UIKit
import Foundation

class MemoImageManager {
    static let shared = MemoImageManager()
    
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Configure cache limits
        cache.countLimit = 50 // Maximum 50 images in cache
        cache.totalCostLimit = 100 * 1024 * 1024 // 100MB memory limit
    }
    
    // MARK: - Image Saving
    
    func saveImage(_ image: UIImage, for memoID: UUID, in itemID: UUID) -> String? {
        // Resize image for storage efficiency
        let resizedImage = image.resized(maxWidth: 1024, maxHeight: 1024)
        let filename = "\(itemID)_\(memoID).jpg"
        
        // Save full image to disk
        guard FileManager.default.saveMemoImage(resizedImage, filename: filename) else {
            return nil
        }
        
        // Create and cache thumbnail
        let thumbnail = resizedImage.resized(maxWidth: 200, maxHeight: 200)
        let thumbnailKey = "thumb_\(filename)" as NSString
        cache.setObject(thumbnail, forKey: thumbnailKey)
        
        // Cache the full image as well for immediate access
        cache.setObject(resizedImage, forKey: filename as NSString)
        
        return filename
    }
    
    // MARK: - Image Loading
    
    func loadImage(filename: String, thumbnail: Bool = false) -> UIImage? {
        let cacheKey = thumbnail ? "thumb_\(filename)" : filename
        
        // Try to get from cache first
        if let cachedImage = cache.object(forKey: cacheKey as NSString) {
            return cachedImage
        }
        
        // Load from disk
        guard let diskImage = FileManager.default.loadMemoImage(filename: filename) else {
            return nil
        }
        
        let imageToCache: UIImage
        if thumbnail {
            imageToCache = diskImage.resized(maxWidth: 200, maxHeight: 200)
        } else {
            imageToCache = diskImage
        }
        
        // Cache the loaded image
        cache.setObject(imageToCache, forKey: cacheKey as NSString)
        
        return imageToCache
    }
    
    func loadThumbnail(filename: String) -> UIImage? {
        return loadImage(filename: filename, thumbnail: true)
    }
    
    func loadFullImage(filename: String) -> UIImage? {
        return loadImage(filename: filename, thumbnail: false)
    }
    
    // MARK: - Image Deletion
    
    func deleteImage(filename: String) {
        // Remove from cache
        cache.removeObject(forKey: filename as NSString)
        cache.removeObject(forKey: "thumb_\(filename)" as NSString)
        
        // Remove from disk
        FileManager.default.deleteMemoImage(filename: filename)
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    func preloadThumbnails(filenames: [String]) {
        Task.detached(priority: .utility) {
            for filename in filenames {
                _ = await Task.detached {
                    self.loadThumbnail(filename: filename)
                }.value
            }
        }
    }
    
    // MARK: - Storage Info
    
    func getStorageSize() -> Int64 {
        return FileManager.default.getMemoImagesDirectorySize()
    }
    
    func formatStorageSize() -> String {
        let bytes = getStorageSize()
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}