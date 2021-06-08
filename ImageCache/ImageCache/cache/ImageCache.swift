//
//  ImageCache.swift
//  ImageCache
//
//  Created by kakao on 2021/06/02.
//

import UIKit

class ImageCache {
    
    internal static let shared = ImageCache()
    private let diskCache = ImageDiskCache.shared
    private let memCache = ImageMemCache.shared
    
    private let queue = DispatchQueue(label: "cache")
    
    private var isDiskCacheEnabled = false

    private init() {
    }
    
    // load image
    func loadImage(url: URL, completion: @escaping ((UIImage?) -> Void) ) {
        
        guard let encodedUrl = url.path.base64Encoding() else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        queue.async { [weak self] in

            if let image = self?.memCache.loadFromMemory(url: encodedUrl) {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            else {
                print("try disk cache")
                if self?.isDiskCacheEnabled == true {
                    let image = self?.diskCache.loadFromDisk(url :encodedUrl)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
                else {
                    do {
                        let data = try Data(contentsOf: url)
                        
                        if let image = UIImage(data: data) {
                            self?.saveImage(image: image, url: encodedUrl)
                            DispatchQueue.main.async {
                                completion(image)
                            }
                        }
                    } catch  {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }

                }
           }
        }
    }
    
    // save image
    private func saveImage(image: UIImage, url: String) {
        guard let encodedUrl = url.base64Encoding() else { return }
        
        // save to memory and disk
        queue.async { [weak self] in
            self?.memCache.saveToMemory(image: image, url: encodedUrl)
            if self?.isDiskCacheEnabled ?? false{
                self?.diskCache.saveToDisk(image: image,url: encodedUrl)
            }
        }
    }

}
