//
//  OAuthOptions.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/15/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

struct OAuthOptions {
    let authorizeEndpoint: URL
    let clientId: String
    let clientSecret: String
    let issuer: URL
    let redirectURI: URL
    let scope: String
    let tokenEndpoint: URL
}

extension OAuthOptions: Decodable {
    enum CodingKeys: String, CodingKey {
        case authorizeEndpoint = "AuthorizeEndpoint"
        case clientId = "ClientId"
        case clientSecret = "ClientSecret"
        case issuer = "Issuer"
        case redirectURI = "RedirectURI"
        case scope = "Scope"
        case tokenEndpoint = "TokenEndpoint"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let authorizeEndpointString = try container.decode(String.self, forKey: .authorizeEndpoint)
        let clientId = try container.decode(String.self, forKey: .clientId)
        let clientSecret = try container.decode(String.self, forKey: .clientSecret)
        let issuerString = try container.decode(String.self, forKey: .issuer)
        let redirectURIString = try container.decode(String.self, forKey: .redirectURI)
        let scope = try container.decode(String.self, forKey: .scope)
        let tokenEndpointString = try container.decode(String.self, forKey: .tokenEndpoint)
        
        let authorizeEndpoint = URL(string: authorizeEndpointString)!
        let issuer = URL(string: issuerString)!
        let redirectURI = URL(string: redirectURIString)!
        let tokenEndpoint = URL(string: tokenEndpointString)!
        
        self.init(authorizeEndpoint: authorizeEndpoint,
                  clientId: clientId,
                  clientSecret: clientSecret,
                  issuer: issuer,
                  redirectURI: redirectURI,
                  scope: scope,
                  tokenEndpoint: tokenEndpoint)
    }
}
