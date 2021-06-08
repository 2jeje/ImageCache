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
    private let queue = DispatchQueue(label: "kakaoCache")
    private var isDiskCacheEnabled = false

    private init() {
    }
    
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
                if self?.isDiskCacheEnabled == true {
                    print("try disk cache")
                    if let diskImage = self?.diskCache.loadFromDisk(url :encodedUrl) {
                        DispatchQueue.main.async {
                            completion(diskImage)
                        }
                    }
                    else {
                        self?.handleNoImageCache(url: url, encodedUrl: encodedUrl, completion: completion)
                    }

                }
                else {
                    self?.handleNoImageCache(url: url, encodedUrl: encodedUrl, completion: completion)
                }
           }
        }
    }
    
    private func handleNoImageCache(url: URL, encodedUrl: String, completion: @escaping ((UIImage?) -> Void)) {
        
        if let image = self.downloadImage(url: url) {
            self.saveImage(image: image, encodedUrl: encodedUrl)
            DispatchQueue.main.async {
                completion(image)
            }
        }
        else {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    private func downloadImage(url: URL) -> UIImage? {
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            print(error)
        }
        return nil
    }
    
    private func saveImage(image: UIImage, encodedUrl: String) {
        queue.async { [weak self] in
            self?.memCache.saveToMemory(image: image, url: encodedUrl)
            if self?.isDiskCacheEnabled ?? false{
                self?.diskCache.saveToDisk(image: image,url: encodedUrl)
            }
        }
    }

}
