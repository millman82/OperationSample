//
//  AuthContext.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/21/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

struct AuthContext {
    
    let options: OAuthOptions
    var tokens: [TokenType:Token] = [:]
    
    init(oauthOptions options: OAuthOptions) {
        self.options = options
    }
}
