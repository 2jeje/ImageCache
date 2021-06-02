//
//  String+PercentEncoding.swift
//  ImageCache
//
//  Created by kakao on 2021/06/02.
//

import Foundation


extension String {
    
    func percentEncoding() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
}
