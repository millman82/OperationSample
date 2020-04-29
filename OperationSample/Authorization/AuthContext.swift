//
//  AuthContext.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/21/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

class AuthContext {
    static let shared: AuthContext = {        
        var plistURL = Bundle.main.url(forResource: "OAuthOptions", withExtension: "plist")!
        let data = try! Data(contentsOf: plistURL)
        
        let decoder = PropertyListDecoder()
        let options = try! decoder.decode(OAuthOptions.self, from: data)
        return AuthContext(oauthOptions: options)
    }()
    
    var authorizationCode: String?
    let options: OAuthOptions
    var tokens: [TokenType:Token] = [:]
    
    init(oauthOptions options: OAuthOptions) {
        self.options = options
    }
}
