//
//  OAuthService.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/14/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import UIKit

enum TokenError: Error {
    case tokenRequestError
    case invalidRefreshToken
    case invalidTokenResponse
}

class OAuthService: AuthService {
    private static var tokens: [TokenType:Token] = [:]
    
    private let discoveryService: DiscoveryService
    private let oauthOptions: OAuthOptions
    
    func getToken(completion: (String) -> Void) {
        if let accessToken = OAuthService.tokens[.accessToken] {
            if accessToken.expires < Date() {
                completion(accessToken.value)
            }
            
            if let refreshToken = OAuthService.tokens[.refreshToken] {
                refreshAccessToken { (result) in
                    switch result {
                    case let .success(token):
                        OAuthService.tokens[.accessToken] = token
                    case let .failure(error):
                        print("Unable to refresh. Prompt for login. \(error)")
                        
                        var loginController = LoginWebViewController(oauthOptions: oauthOptions, coder: NSCoder())
                        //loginController.present()
                    }
                }
            }
        }
    }
    
    private func refreshAccessToken(completion: (Result<Token, TokenError>) -> Void) {
        
    }
    
    
    
    init(discoveryService: DiscoveryService, oauthOptions: OAuthOptions) {
        self.discoveryService = discoveryService
        self.oauthOptions = oauthOptions
    }
}
