//
//  ImageCache.swift
//  ImageCache
//
//  Created by kakao on 2021/06/02.
//

import UIKit

class ImageCache {
    
    public static let shared = ImageCache()
    
    let queue = DispatchQueue(label: "cache")
    var images = NSCache<NSString, UIImage>() // NSCache is Thread-Safe
    
    init() {
        images.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func saveImage(image: UIImage, url: String) {
        cacheToMemory(image, url)
        cacheToDisk(image, url)
    }
    
    func loadImage(url: String) {
    }
    
    open func clearImages() {
        
        images.removeAllObjects()
        
        let fileManager = FileManager.default
        guard let cacheDefaultUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        
        if fileManager.isDeletableFile(atPath: cacheDefaultUrl.path) {
            do {
                try fileManager.removeItem(atPath: cacheDefaultUrl.path)
            } catch {
                debugPrint(error.localizedDescription)
            }
            
        }
        
        //workItems.removeAllObjects()
    }
    
    
    private func cacheToMemory(_ image: UIImage, _ url: String) {
        images.setObject(image, forKey: url as NSString)
    }
    
    private func cacheToDisk(_ image: UIImage, _ url: String) {
        guard let cacheDefaultUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        
        let cacheUrl = cacheDefaultUrl.appendingPathComponent(url)
        if let data = image.pngData() {
            do {
                try data.write(to: cacheUrl, options: Data.WritingOptions.atomic)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    private func loadFromMemory() {
        
    }
    
    private func loadFromDisk() {
        
    }
}
