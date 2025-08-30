//
//  FileManager+Extensions.swift
//  OneBookAMonth
//
//  Created by delightroom on 2/8/25.
//

import Foundation
import UIKit

extension FileManager {
    static let memoImagesDirectory: URL = {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let memoImagesPath = documentsPath.appendingPathComponent("MemoImages")
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: memoImagesPath.path) {
            try? FileManager.default.createDirectory(at: memoImagesPath, withIntermediateDirectories: true)
        }
        
        return memoImagesPath
    }()
    
    func saveMemoImage(_ image: UIImage, filename: String) -> Bool {
        let fileURL = Self.memoImagesDirectory.appendingPathComponent(filename)
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return false }
        
        do {
            try imageData.write(to: fileURL)
            return true
        } catch {
            print("Error saving memo image: \(error)")
            return false
        }
    }
    
    func loadMemoImage(filename: String) -> UIImage? {
        let fileURL = Self.memoImagesDirectory.appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func deleteMemoImage(filename: String) -> Bool {
        let fileURL = Self.memoImagesDirectory.appendingPathComponent(filename)
        
        do {
            try removeItem(at: fileURL)
            return true
        } catch {
            print("Error deleting memo image: \(error)")
            return false
        }
    }
    
    func getMemoImagesDirectorySize() -> Int64 {
        guard let files = try? contentsOfDirectory(
            at: Self.memoImagesDirectory,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else { return 0 }
        
        return files.compactMap { url in
            try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize
        }.reduce(0) { $0 + Int64($1) }
    }
    
    func cleanupOrphanedMemoImages(validFilenames: Set<String>) {
        guard let files = try? contentsOfDirectory(at: Self.memoImagesDirectory, includingPropertiesForKeys: nil) else { return }
        
        for fileURL in files {
            let filename = fileURL.lastPathComponent
            if !validFilenames.contains(filename) {
                try? removeItem(at: fileURL)
                print("Cleaned up orphaned memo image: \(filename)")
            }
        }
    }
}