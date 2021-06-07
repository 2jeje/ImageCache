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
        guard let encodedUrl = url.base64Encoding() else { return }
        
        // save to memory and disk
        queue.async { [weak self] in
            self?.memCache.saveToMemory(image: image, url: encodedUrl)
            self?.diskCache.saveToDisk(image: image,url: encodedUrl)
        }
    }
    
    // load image
    func loadImage(url: String, completion: @escaping ((UIImage?) -> Void) ) {
        
        guard let encodedUrl = url.base64Encoding() else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        //todo
        queue.async { [weak self] in

            if let image = self?.memCache.loadFromMemory(url: encodedUrl) {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            else {
                print("try disk cache")
                let image = self?.diskCache.loadFromDisk(url :encodedUrl)
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
