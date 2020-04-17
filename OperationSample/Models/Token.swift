//
//  Token.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/14/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

enum TokenType: NSString {
    case accessToken = "AccessToken"
    case refreshToken = "RefreshToken"
}

class Token {
    let value: String
    let expires: Date
    
    init(_ token: String, expires: Date)
    {
        self.value = token
        self.expires = expires
    }
}
