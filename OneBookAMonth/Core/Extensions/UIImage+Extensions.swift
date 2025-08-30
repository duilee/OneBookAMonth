//
//  UIImage+Extensions.swift
//  OneBookAMonth
//
//  Created by delightroom on 2/8/25.
//

import UIKit

extension UIImage {
    func resized(maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage {
        let size = self.size
        
        if size.width <= maxWidth && size.height <= maxHeight {
            return self
        }
        
        let widthRatio = maxWidth / size.width
        let heightRatio = maxHeight / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        let newSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func resized(to targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}