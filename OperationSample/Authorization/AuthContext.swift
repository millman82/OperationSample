//
//  AuthContext.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/21/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

class AuthContext {
    private let isolationQueue = DispatchQueue(label: "com.timmiller.operationsample.authcontext.isolation", attributes: .concurrent)
    private var tokens: [TokenType:Token] = [:]
    
    static let shared: AuthContext = {        
        var plistURL = Bundle.main.url(forResource: "OAuthOptions", withExtension: "plist")!
        let data = try! Data(contentsOf: plistURL)
        
        let decoder = PropertyListDecoder()
        let options = try! decoder.decode(OAuthOptions.self, from: data)
        return AuthContext(oauthOptions: options)
    }()
    
    var authorizationCode: String?
    let options: OAuthOptions
    
    func clearTokens() {
        isolationQueue.async(flags: .barrier) {
            self.tokens = [:]
        }
    }
    
    func getToken(type: TokenType) -> Token? {
        isolationQueue.sync {
            return tokens[type]
        }
    }
    
    func setToken(for type: TokenType, token: Token) {
        isolationQueue.async(flags: .barrier) {
            self.tokens[type] = token
        }
    }
    
    private init(oauthOptions options: OAuthOptions) {
        self.options = options
    }
}
