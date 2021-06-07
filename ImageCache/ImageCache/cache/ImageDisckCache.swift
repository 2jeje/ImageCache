//
//  ImageDisckCache.swift
//  ImageCache
//
//  Created by kakao on 2021/06/03.
//

import UIKit

class ImageDiskCache {
    
    public static let shared = ImageDiskCache()
    
    var diskPath : URL?
    
    var disckCacheSize = {
        return 100 * 1024 * 1024 // 100MB
    }
    
    var currentDiskCacheSize : UInt64 = 0
    
    init() {
        diskPath = mkdir()
        currentDiskCacheSize = calculateDiskCacheSize()
    }
    
    func saveToDisk(image: UIImage, url: String) {
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
    
    func loadFromDisk(url: NSString) -> UIImage? {
        //todo
        return nil
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
    
    private func calculateDiskCacheSize() -> UInt64{
        //todo
        guard let path = diskPath else {
            return 0
        }
        
        let files = FileManager.default.subpaths(atPath: path.absoluteString)
        var fileSize :UInt64 = 0

        guard let files = files else { return 0 }
        
        for file in files {
            
            let filePath = path.appendingPathComponent(file)
            do {
                let fileAttr = try FileManager.default.attributesOfItem(atPath: filePath.absoluteString)
                fileSize += (fileAttr[FileAttributeKey.size] as? UInt64 ?? 0)
            }
            catch {
                print(error)
                continue
            }

        }
        return fileSize
    }
}
