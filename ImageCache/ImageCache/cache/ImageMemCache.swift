//
//  ImageMemCache.swift
//  ImageCache
//
//  Created by kakao on 2021/06/03.
//

import UIKit


internal class ImageMemCache {
    
    internal static let shared = ImageMemCache()
    
    private var memoryCacheSize = 50 * 1024 * 1024 // 50MB
    
    private var images = NSCache<NSString, UIImage>() // NSCache is Thread-Safe
    
    private init() {
        // allocate memory cache size
        images.totalCostLimit = memoryCacheSize
    }
    
    
    internal func saveToMemory(image: UIImage, url: String) {
        if let data = image.pngData(){
            images.setObject(image, forKey: NSString(string: url), cost: data.count)
        }
    }
    
    
    internal func loadFromMemory(url: String) -> UIImage? {
        images.object(forKey: NSString(string: url))
    }
    
}
