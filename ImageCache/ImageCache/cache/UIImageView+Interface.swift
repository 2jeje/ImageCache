//
//  UIImageView.swift
//  ImageCache
//
//  Created by kakao on 2021/06/08.
//

import UIKit

internal typealias ImageCacheImageView = UIImageView

internal struct ImageCacheWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

internal protocol ImageCacheCompatible: AnyObject { }

internal extension ImageCacheCompatible {
    var kakao: ImageCacheWrapper<Self> {
        get { return ImageCacheWrapper(self) }
        set { }
    }
}

extension ImageCacheImageView: ImageCacheCompatible{}

internal extension ImageCacheWrapper where Base: ImageCacheImageView  {
    func setImage(url: URL) {
        ImageCache.shared.loadImage(url: url, completion: {
            self.base.image = $0
        })
    }
}
