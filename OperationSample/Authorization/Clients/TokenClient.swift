//
//  TokenClient.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/25/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

struct TokenClient {
    private let oauthOptions: OAuthOptions = {
        return AuthContext.shared.options
    }()
    
    
}
