//
//  DiscoveryInfo.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/15/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

class DiscoveryInfo: Decodable {
    let issuer: String
    let authorizationEndpoint: String
    let tokenEndpoint: String
    let userInfoEndpoint: String
    
    enum CodingKeys: String, CodingKey {
        case issuer
        case authorizationEndpoint = "authorization_endpoint"
        case tokenEndpoint = "token_endpoint"
        case userInfoEndpoint = "userinfo_endpoint"
    }
}
