//
//  OAuthService.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/14/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import UIKit
import CryptoKit
import AuthenticationServices

enum OperationTypes {
    case authorize
    case token
    case refresh
}

class OAuthOperation: Operation {
    var operationsInProgress = [OperationTypes:Operation]()
    lazy var operationQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "OAuth Queue"
        //queue.maxConcurrentOperationCount = 1
        queue.isSuspended = true
        return queue
    }()
    
    private var accessToken: String?
    private var codeVerifier: String?
    private let options: OAuthOptions
    private let globalPresentationAnchor: ASPresentationAnchor?
    
    private let completion: (String?) -> Void
    
    override var isAsynchronous: Bool {
        return true
    }
    
    private var _isExecuting: Bool = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _isExecuting
    }
    
    private var _isFinished: Bool = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _isFinished
    }
    
    override func main() {
        if !isCancelled {
            getToken()
        }
    }
    
    override func start() {
        if !isCancelled {
            _isExecuting = true
            main()
        } else {
            _isFinished = true
        }
    }
    
    init(oauthOptions options: OAuthOptions, globalPresentationAnchor: ASPresentationAnchor?, completion: @escaping (String?) -> Void)
    {
        self.options = options
        self.globalPresentationAnchor = globalPresentationAnchor
        self.completion = completion
    }
    
    private func getToken() {
        if !isCancelled {
            let tokenLookupOperation = BlockOperation { [unowned self] in
                self.lookupCachedToken()
            }
            
            operationQueue.addOperation(tokenLookupOperation)
            operationQueue.isSuspended = false
        } else {
            _isExecuting = false
            _isFinished = true
        }

        if !isCancelled {
            if let refreshToken = AuthContext.shared.tokens[.refreshToken] {
                if !operationsInProgress.keys.contains(.refresh) {
                    let refreshTokenOperation = refreshAccessToken(refreshToken.value)
                    let tokenLookupOperation = BlockOperation { [unowned self] in
                        self.lookupCachedToken()
                    }
                    operationsInProgress[.refresh] = refreshTokenOperation
                    tokenLookupOperation.addDependency(refreshTokenOperation)
                    
                    operationQueue.addOperation(refreshTokenOperation)
                    operationQueue.addOperation(tokenLookupOperation)
                    
                    operationQueue.isSuspended = false
                }
            } else {
                if !operationsInProgress.keys.contains(.token) {
                    codeVerifier = UUID().uuidString + UUID().uuidString
                    let authorizeOperation = authorize()
                    authorizeOperation.completionBlock = {
                        self.operationsInProgress.removeValue(forKey: .authorize)
                    }
                    let tokenOperation = retrieveTokens()
                    let tokenLookupOperation = BlockOperation { [unowned self] in
                        self.lookupCachedToken()
                    }
                    operationsInProgress[.authorize] = authorizeOperation
                    operationsInProgress[.token] = tokenOperation
                    tokenOperation.addDependency(authorizeOperation)
                    tokenLookupOperation.addDependency(tokenOperation)
                    
                    operationQueue.addOperation(authorizeOperation)
                    operationQueue.addOperation(tokenOperation)
                    operationQueue.addOperation(tokenLookupOperation)
                    
                    operationQueue.isSuspended = false
                }
            }
        } else {
            _isExecuting = false
            _isFinished = true
        }
    }
    
    private func authorize() -> AuthorizeOperation {
        AuthContext.shared.tokens = [:]
        
        let scheme = self.options.redirectURI.scheme ?? ""
        
        let parameters: [String:Any] = [
            "client_id": self.options.clientId,
            "redirect_uri": self.options.redirectURI.absoluteString,
            "scope": self.options.scope
        ]
        
        let authorizeOperation = AuthorizeOperation(
            options.authorizeEndpoint,
            callbackRULScheme: scheme,
            codeVerifier: codeVerifier,
            parameters: parameters,
            globalPresentationAnchor: globalPresentationAnchor)
        
        return authorizeOperation
    }
    
    private func lookupCachedToken() {
        if let storedAccessToken = AuthContext.shared.tokens[.accessToken], let expires = storedAccessToken.expires, Date() < expires {
            accessToken = storedAccessToken.value
            self.completion(accessToken)
            _isExecuting = false
            _isFinished = true
        }
        
        operationQueue.isSuspended = true
    }
    
    private func retrieveTokens() -> TokenOperation {
        var parameters: [String:Any] = [
            "client_id" : options.clientId,
            "grant_type" : "authorization_code",
            "client_secret" : options.clientSecret,
            "redirect_uri" : options.redirectURI.absoluteString
        ]
        
        if let codeVerifier = codeVerifier {
            parameters["code_verifier"] = codeVerifier
        }
        
        let tokenOperation = TokenOperation(options.tokenEndpoint, parameters: parameters, completion: handleTokenResult(result:))
        
        return tokenOperation
    }
    
    private func refreshAccessToken(_ refreshToken: String) -> TokenOperation {
        let parameters: [String:Any] = [
            "client_id" : options.clientId,
            "grant_type" : "refresh_token",
            "refresh_token" : refreshToken,
            "client_secret" : options.clientSecret
        ]
        
        let tokenOperation = TokenOperation(options.tokenEndpoint, parameters: parameters, completion: handleTokenResult(result:))
        
        return tokenOperation
    }
    
    func handleTokenResult(result: Result<TokenResponse, TokenError>) {
        switch result {
        case let .success(tokenResponse):
            AuthContext.shared.tokens[.accessToken] = Token(value: tokenResponse.accessToken, expires: tokenResponse.expiry)

            if let refreshToken = tokenResponse.refreshToken {
                AuthContext.shared.tokens[.refreshToken] = Token(value: refreshToken, expires: nil)
            }
        case let .failure(error):
            print(error)
        }
        
        if operationsInProgress.keys.contains(.token) {
            operationsInProgress.removeValue(forKey: .token)
        } else if operationsInProgress.keys.contains(.refresh) {
            operationsInProgress.removeValue(forKey: .refresh)
        }
    }
}
