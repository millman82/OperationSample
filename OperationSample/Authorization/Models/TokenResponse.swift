//
//  TokenResponse.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/20/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

struct TokenResponse {
    let accessToken: String
    let expiry: Date
    let tokenType: String
    let refreshToken: String?
}

extension TokenResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiry = "expires_in"
        case tokenType = "token_type"
        case refreshToken = "refresh_token"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let accessToken = try container.decode(String.self, forKey: .accessToken)
        let expiresIn = try container.decode(Double.self, forKey: .expiry)
        
        var expiry = Date()
        if let interval = TimeInterval(exactly: expiresIn) {
            expiry += interval
        }
        
        let tokenType = try container.decode(String.self, forKey: .tokenType)
        let refreshToken = try container.decode(String.self, forKey: .refreshToken)
        
        self.init(accessToken: accessToken, expiry: expiry, tokenType: tokenType, refreshToken: refreshToken)
    }
}
