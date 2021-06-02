//
//  ImageCache.swift
//  ImageCache
//
//  Created by kakao on 2021/06/02.
//

import UIKit

class ImageCache {
    
    public static let shared = ImageCache()
    
    var memoryCacheSize = {
        return 50 * 1024 * 1024 // 50MB
    }
    
    var disckCacheSize = {
        return 100 * 1024 * 1024 // 100MB
    }
    
    var images = NSCache<NSString, UIImage>() // NSCache is Thread-Safe
    var diskPath : URL?
    
    let queue = DispatchQueue(label: "cache")

    init() {
        images.totalCostLimit = memoryCacheSize()
        diskPath = mkdir()
    }
    
    func saveImage(image: UIImage, url: String) {
        guard let encodedUrl = url.percentEncoding() else { return }
        
        cacheToMemory(image, encodedUrl)
        cacheToDisk(image, encodedUrl)
    }
    
    func loadImage(url: String, completion: @escaping ((UIImage?) -> Void) ) {
        
        guard let encodedUrl = url.percentEncoding() else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        //todo
        
        DispatchQueue(label: "imagecache").async { [weak self] in

            if let image = self?.images.object(forKey: NSString(string: encodedUrl)) {
                completion(image)
            }
        }
    }
    
    func clearImages() {
        
        images.removeAllObjects()
        
        let fileManager = FileManager.default
        guard let cacheDefaultUrl = diskPath else {
            return
        }
        
        if fileManager.isDeletableFile(atPath: cacheDefaultUrl.path) {
            do {
                try fileManager.removeItem(atPath: cacheDefaultUrl.path)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
        diskPath = nil

    }
    
    
    private func cacheToMemory(_ image: UIImage, _ url: String) {
        images.setObject(image, forKey: url as NSString)
    }
    
    private func cacheToDisk(_ image: UIImage, _ url: String) {
        guard let cacheDefaultUrl = diskPath else {
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
    
    private func loadFromMemory(_ url: NSString) -> UIImage? {
        return images.object(forKey: url)
        
    }
    
    private func loadFromDisk(_ url: NSString) -> UIImage? {
        //todo
        return nil
    }
    
    private func currentDiskCacheSize() -> Int64{
        //todo
        return 0
    }
    
    private func mkdir() -> URL? {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        
        if (paths.count <= 0) {
            return nil
        }
        
        let path = paths[0]
        
        guard let pathUrl = URL(string: path) else {
            return nil
        }

        let fullPath = pathUrl.appendingPathComponent("cache")
        if !FileManager.default.fileExists(atPath: fullPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: fullPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        
        return fullPath
    }
}
