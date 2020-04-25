//
//  String+URL.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/21/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

extension String {
    var urlEncoded: String {
        let customAllowedSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
    }
}

extension String.Encoding {
    var charset: String {
        let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.rawValue))
        
        return charset! as String
    }
}
