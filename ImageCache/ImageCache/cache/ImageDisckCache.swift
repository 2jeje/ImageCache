//
//  ImageDisckCache.swift
//  ImageCache
//
//  Created by kakao on 2021/06/03.
//

import UIKit

class ImageDiskCache {
   
    public static let shared = ImageDiskCache()
    
    var diskPath: URL?
    
    var disckCacheSize: UInt64 = UInt64(100 * 1024 * 1024) // 100MB

    var currentDiskCacheSize: UInt64 = 0
    
    init() {
        loadDiskCache()
    }

    func saveToDisk(image: UIImage, url: String) {
        guard let cacheDefaultUrl = diskPath else {
            return
        }

        let cacheUrl = cacheDefaultUrl.appendingPathComponent(url)
 
        if let data = image.pngData() {

            let size = currentDiskCacheSize + UInt64(data.count)
            print("fileSize: \(UInt64(data.count))")
            if (size >= disckCacheSize) {
                // 삭제
                repeat {
                    if let cache = DiskCacheStorage.shared.pop() {
                        currentDiskCacheSize -= cache.size
                        removeFile(url: cache.path)
                    }

                } while (!(currentDiskCacheSize < disckCacheSize))
            }

            do {
              //  print("write: \(cacheUrl)")
                try data.write(to: cacheUrl, options: Data.WritingOptions.atomic)

            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
        
        print("currentDiskCacheSize: \(currentDiskCacheSize)")
    }

    func loadFromDisk(url: String) -> UIImage? {
        guard let cacheDefaultUrl = diskPath else {
            return nil
        }

        let cacheUrl = cacheDefaultUrl.appendingPathComponent(url)

        return UIImage(contentsOfFile: cacheUrl.path)
    }

    private func removeFile(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        }catch {
            print(error)
        }
    }
//
    private func mkdir() -> URL? {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        if (paths.count <= 0) {
            return nil
        }
        var path = paths[0]
        path.appendPathComponent("cache", isDirectory: true)

        if !FileManager.default.fileExists(atPath: path.path) {
            print("DDDD")
            do {
                try FileManager.default.createDirectory(atPath: path.path, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print(error)
                return path
            }
        }

        return path
    }

    private func loadDiskCache(){
        diskPath = mkdir()

        guard let path = diskPath else { return }
        var files: [String] = []

        do {
            files = try FileManager.default.contentsOfDirectory(atPath: diskPath!.path)
        }
        catch {
            print(error)
            return
        }
        
        currentDiskCacheSize = 0
        for file in files {
            let filePath = path.appendingPathComponent(file)
            do {
                let fileAttr = try FileManager.default.attributesOfItem(atPath: filePath.path)
                if let size = fileAttr[FileAttributeKey.size] as? UInt64, let createdAt = fileAttr[FileAttributeKey.creationDate] as? Date {
                    DiskCacheStorage.shared.load(cache: DiskCache(createAt: UInt64(createdAt.timeIntervalSince1970), size: size, path: filePath))
                    currentDiskCacheSize += size
                }
            }
            catch {
                print(error)
                continue
            }
        }

        DiskCacheStorage.shared.sort()
    }
}

struct DiskCache {
    var createAt: UInt64
    var size: UInt64
    var path: URL
}

class DiskCacheStorage {

    var caches: [DiskCache] = []

    static var shared = DiskCacheStorage()

    func load(cache: DiskCache) {
        self.caches.append(cache)
    }

    func sort() {
    }

    func push(cache: DiskCache) {
        self.caches.append(cache)
        // todo sorting
    }

    func pop() -> DiskCache? {
        if caches.count <= 0 { return nil }
        let first = caches.first
        caches.remove(at: 0)
        return first
    }
}
