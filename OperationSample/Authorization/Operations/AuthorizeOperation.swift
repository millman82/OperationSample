//
//  AuthorizeOperation.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/26/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import AuthenticationServices
import CryptoKit
import Foundation

class AuthorizeOperation: AsyncOperation {
    lazy var authorizeQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.name = "Authorize Queue"
        operationQueue.maxConcurrentOperationCount = 1
        return operationQueue
    }()
    
    private let authorizeEndpoint: URL
    private let callbackURLScheme: String
    private let codeVerifier: String?
    private let parameters: [String:Any]
    private let globalPresentationAnchor: ASPresentationAnchor?
    
    override func main() {
        if !isCancelled {
            authorize()
        } else {
            finish()
        }
    }
    
    init(_ authorizeEndpoint: URL, callbackRULScheme: String, codeVerifier: String?, parameters: [String:Any], globalPresentationAnchor: ASPresentationAnchor?)
    {
        self.authorizeEndpoint = authorizeEndpoint
        self.callbackURLScheme = callbackRULScheme
        self.codeVerifier = codeVerifier
        self.parameters = parameters
        self.globalPresentationAnchor = globalPresentationAnchor
    }
    
    private func authorize() {
        var codeChallenge: String? = nil
        
        if !isCancelled, let codeVerifier = codeVerifier, let codeVerifierData = codeVerifier.data(using: .utf8) {
            let sha256 = SHA256.hash(data: codeVerifierData)
            codeChallenge = sha256.withUnsafeBytes { (pointer) -> String in
                
                let data = Data(bytes: pointer.baseAddress!, count: pointer.count)
                let encodedData = data.base64EncodedData()
                
                return String(data: encodedData, encoding: .ascii)!
            }
        }
            
        guard var urlComponents = URLComponents(url: authorizeEndpoint, resolvingAgainstBaseURL: false) else { return }
        
        var query: [String:Any] = parameters
        
        query["response_type"] = "code"
        
        if let encodedChallenge = codeChallenge?.replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "") {
            
            query["code_challenge"] = encodedChallenge
            query["code_challenge_method"] = "S256"
        }
        
        let csrf = UUID().uuidString
        query["state"] = csrf.urlEncoded
        
        urlComponents.query = query.urlEncodedQuery
        
        guard let authURL = urlComponents.url else { return }
        
        if !isCancelled {
            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackURLScheme) { (callbackURL, error) in
                defer {
                    self.finish()
                }
                if let error = error {
                    print(error)
                }
                
                guard let callbackURL = callbackURL else { return }
                print(callbackURL)
                let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
                
                guard let state = queryItems?.filter({ $0.name == "state" }).first?.value, state == csrf else {
                    print("Invalid response: state corrupt")
                    return
                }
                
                if let code = queryItems?.filter({ $0.name == "code" }).first?.value {
                    AuthContext.shared.authorizationCode = code
                }
            }
            
            OperationQueue.main.addOperation {
                let oAuthViewController = OAuthViewController()
                oAuthViewController.globalPresentationAnchor = ASPresentationAnchor()
                let presentationContextProvider = oAuthViewController
                
                session.presentationContextProvider = presentationContextProvider
                session.start()
            }
        } else {
            finish()
        }
    }
}
