//
//  OAuthService.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/14/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

class OAuthService: AuthService {
    private static let cache = NSCache<NSString, Token>()
    
    private let discoveryService: DiscoveryService
    
    func getToken() {
        
    }
    
    init(discoveryService: DiscoveryService) {
        self.discoveryService = discoveryService
    }
}
