//
//  ImageMemCache.swift
//  ImageCache
//
//  Created by kakao on 2021/06/03.
//

import UIKit


class ImageMemCache {
    
    public static let shared = ImageMemCache()
    
    var memoryCacheSize = {
        return 50 * 1024 * 1024 // 50MB
    }
    
    var images = NSCache<NSString, UIImage>() // NSCache is Thread-Safe
    
    init() {
        // allocate memory cache size
        images.totalCostLimit = memoryCacheSize()
    }
    
    
    func saveToMemory(image: UIImage, url: NSString) {
        images.setObject(image, forKey: url)
    }
    
    
    func loadFromMemory(url: NSString) -> UIImage? {
        images.object(forKey: url)
    }
    
}
