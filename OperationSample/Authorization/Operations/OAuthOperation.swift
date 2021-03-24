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

enum OperationType {
    case token
    case refresh
}

class OAuthOperation: AsyncOperation {
    private var operationsInProgress = [OperationType:Operation]()
    
    private static let operationQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "OAuth Queue"
        queue.isSuspended = true
        return queue
    }()
    
    private var accessToken: String?
    private var codeVerifier: String?
    private let options: OAuthOptions
    private let globalPresentationAnchor: ASPresentationAnchor?
    
    private let completion: (String?) -> Void
    
    override func main() {
        if !isCancelled {
            getToken()
        }
    }
    
    init(oAuthOptions options: OAuthOptions, globalPresentationAnchor: ASPresentationAnchor?, completion: @escaping (String?) -> Void)
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
            
            OAuthOperation.operationQueue.addOperation(tokenLookupOperation)
            OAuthOperation.operationQueue.isSuspended = false
        } else {
            finish()
            return
        }

        if !isCancelled {
            if let refreshToken = AuthContext.shared.getToken(type: .refreshToken) {
                if !operationsInProgress.keys.contains(.refresh) {
                    let refreshTokenOperation = refreshAccessToken(refreshToken.value)
                    refreshTokenOperation.completionBlock = {
                        self.operationsInProgress.removeValue(forKey: .refresh)
                    }
                    let tokenLookupOperation = BlockOperation { [unowned self] in
                        self.lookupCachedToken()
                    }
                    operationsInProgress[.refresh] = refreshTokenOperation
                    tokenLookupOperation.addDependency(refreshTokenOperation)
                    
                    OAuthOperation.operationQueue.addOperation(refreshTokenOperation)
                    OAuthOperation.operationQueue.addOperation(tokenLookupOperation)
                    
                    OAuthOperation.operationQueue.isSuspended = false
                }
            } else {
                if !operationsInProgress.keys.contains(.token) {
                    codeVerifier = UUID().uuidString + UUID().uuidString
                    let authorizeOperation = authorize()
                    let tokenOperation = retrieveTokens()
                    tokenOperation.completionBlock = {
                        self.operationsInProgress.removeValue(forKey: .token)
                    }
                    let tokenLookupOperation = BlockOperation { [unowned self] in
                        self.lookupCachedToken()
                    }
                    operationsInProgress[.token] = tokenOperation
                    tokenOperation.addDependency(authorizeOperation)
                    tokenLookupOperation.addDependency(tokenOperation)
                    
                    OAuthOperation.operationQueue.addOperation(authorizeOperation)
                    OAuthOperation.operationQueue.addOperation(tokenOperation)
                    OAuthOperation.operationQueue.addOperation(tokenLookupOperation)
                    
                    OAuthOperation.operationQueue.isSuspended = false
                }
            }
        } else {
            finish()
        }
    }
    
    private func authorize() -> AuthorizeOperation {
        AuthContext.shared.clearTokens()
        
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
        if let storedAccessToken = AuthContext.shared.getToken(type: .accessToken), let expires = storedAccessToken.expires, Date() < expires {
            accessToken = storedAccessToken.value
            self.completion(accessToken)
            finish()
        }
        
        OAuthOperation.operationQueue.isSuspended = true
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
            AuthContext.shared.setToken(for: .accessToken, token: Token(value: tokenResponse.accessToken, expires: tokenResponse.expiry))

            if let refreshToken = tokenResponse.refreshToken {
                AuthContext.shared.setToken(for: .refreshToken, token: Token(value: refreshToken, expires: nil))
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
