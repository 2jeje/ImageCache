//
//  ImageMemCache.swift
//  ImageCache
//
//  Created by kakao on 2021/06/03.
//

import UIKit


class ImageMemCache {
    
    public static let shared = ImageMemCache()
    
    var memoryCacheSize = 10//50 * 1024 * 1024 // 50MB
    
    var images = NSCache<NSString, UIImage>() // NSCache is Thread-Safe
    
    init() {
        // allocate memory cache size
        images.totalCostLimit = memoryCacheSize
    }
    
    
    func saveToMemory(image: UIImage, url: String) {
        images.setObject(image, forKey: NSString(string: url))
    }
    
    
    func loadFromMemory(url: String) -> UIImage? {
        images.object(forKey: NSString(string: url))
    }
    
}
