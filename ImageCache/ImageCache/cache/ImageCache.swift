//
//  ImageCache.swift
//  ImageCache
//
//  Created by kakao on 2021/06/02.
//

import UIKit

class ImageCache {
    
    public static let shared = ImageCache()
    
    let diskCache = ImageDiskCache.shared
    let memCache = ImageMemCache.shared
    
    let queue = DispatchQueue(label: "cache")

    init() {
    }
    
    // save image
    func saveImage(image: UIImage, url: String) {
        guard let encodedUrl = url.percentEncoding() else { return }
        
        // save to memory and disk
        memCache.saveToMemory(image: image, url: NSString(string: encodedUrl))
        diskCache.saveToDisk(image: image,url: encodedUrl)
    }
    
    // load image
    func loadImage(url: String, completion: @escaping ((UIImage?) -> Void) ) {
        
        guard let encodedUrl = url.percentEncoding() else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        //todo
        DispatchQueue(label: "imagecache").async { [weak self] in

            if let image = self?.memCache.loadFromMemory(url: NSString(string: encodedUrl)) {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            else {
                let image = self?.diskCache.loadFromDisk(url :NSString(string: encodedUrl))
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
    // need?
    func clearImages() {
        
//        images.removeAllObjects()
//
//        let fileManager = FileManager.default
//        guard let cacheDefaultUrl = diskPath else {
//            return
//        }
//
//        if fileManager.isDeletableFile(atPath: cacheDefaultUrl.path) {
//            do {
//                try fileManager.removeItem(atPath: cacheDefaultUrl.path)
//            } catch {
//                debugPrint(error.localizedDescription)
//            }
//        }
//        diskPath = nil

    }

}
