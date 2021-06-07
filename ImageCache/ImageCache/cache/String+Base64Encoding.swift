//
//  String+PercentEncoding.swift
//  ImageCache
//
//  Created by kakao on 2021/06/02.
//

import Foundation


extension String {
    
    func base64Encoding() -> String? {
        return self.data(using: .utf8)?.base64EncodedString()
    }
}
