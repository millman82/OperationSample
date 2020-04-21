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

enum AuthorizationError: Error {
    case authorizationFailed
}

enum TokenError: Error {
    case tokenRequestError
    case invalidRefreshToken
    case invalidTokenResponse
}

class OAuthService: AuthService {
    private static var tokens: [TokenType:Token] = [:]
    
    private let oauthOptions: OAuthOptions = {
        return AuthContext.shared.options
    }()
    
    func getToken(requestingViewController: UIViewController, completion: @escaping (String) -> Void) {
        if let accessToken = OAuthService.tokens[.accessToken], let expires = accessToken.expires, expires < Date() {
            completion(accessToken.value)
        }
            
        let codeVerifier = UUID().uuidString + UUID().uuidString
        
        let tokenRetreivalCallback = { (result: Result<TokenResponse, TokenError>) -> Void in
            switch result {
            case let .success(tokenResponse):
                AuthContext.shared.tokens[.accessToken] = Token(value: tokenResponse.accessToken, expires: tokenResponse.expiry)
                
                if let refreshToken = tokenResponse.refreshToken {
                    AuthContext.shared.tokens[.refreshToken] = Token(value: refreshToken, expires: nil)
                }
                
                completion(tokenResponse.accessToken)
            case let .failure(error):
                print(error)
            }
        }
        
        let loginCallback = { (result: Result<String,AuthorizationError>) -> Void in
            switch result {
            case let .success(code):
                self.retrieveTokens(code: code, codeVerifier: codeVerifier, completion: tokenRetreivalCallback)
            case let .failure(error):
                print(error)
            }
            
        }
        
        if let refreshToken = OAuthService.tokens[.refreshToken] {
            refreshAccessToken { (result) in
                switch result {
                case let .success(tokenResponse):
                    OAuthService.tokens[.accessToken] = Token(value: tokenResponse.accessToken, expires: tokenResponse.expiry)
                    if let refreshToken = tokenResponse.refreshToken {
                        OAuthService.tokens[.refreshToken] = Token(value: refreshToken, expires: nil)
                    }
                case let .failure(error):
                    print("Unable to refresh. Prompt for login. \(error)")
                    
                    OAuthService.tokens = [:]
                    authorize(requestingViewController: requestingViewController, codeVerifier: codeVerifier, completion: loginCallback)
                }
            }
        } else {
            authorize(requestingViewController: requestingViewController, codeVerifier: codeVerifier, completion: loginCallback)
        }
    }
    
    func authorize(requestingViewController: UIViewController, codeVerifier: String, completion: @escaping (Result<String,AuthorizationError>) -> Void) {
        if let strData = codeVerifier.data(using: .utf8) {
            let sha256 = SHA256.hash(data: strData)
            let codeChallenge = sha256.withUnsafeBytes { (pointer) -> String in
                
                let data = Data(bytes: pointer.baseAddress!, count: pointer.count)
                let encodedData = data.base64EncodedData()
                
                return String(data: encodedData, encoding: .ascii)!
            }
            
            guard var urlComponents = URLComponents(string: "https://demo.identityserver.io/connect/authorize") else { return }
            
            let csrf = UUID().uuidString
            
            let encodedChallenge = codeChallenge.replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
            
            let query: [String:Any] = [
                "response_type": "code",
                "client_id": oauthOptions.clientId,
                "code_challenge": encodedChallenge,
                "code_challenge_method": "S256",
                "redirect_uri": oauthOptions.redirectURI.absoluteString,
                "scope": oauthOptions.scope,
                "state": csrf.urlEncoded
            ]
            
            urlComponents.query = query.urlEncodedQuery
            
            guard let authURL = urlComponents.url else { return }
            
            print(authURL)
            
            let scheme = oauthOptions.redirectURI.scheme
            
            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { (callbackURL, error) in
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
                    completion(.success(code))
                } else {
                    completion(.failure(.authorizationFailed))
                }
            }
            
            session.presentationContextProvider = requestingViewController
            session.start()
        }
    }
    
    private func retrieveTokens(code: String, codeVerifier: String, completion: @escaping (Result<TokenResponse, TokenError>) -> Void) {
        guard let url = URL(string: "https://demo.identityserver.io/connect/token") else {
            completion(.failure(.tokenRequestError))
            return
        }
        
        var parameters: [String:Any] = [:]
        parameters["client_id"] = oauthOptions.clientId
        parameters["code"] = code
        parameters["grant_type"] = "authorization_code"
        parameters["code_verifier"] = codeVerifier
        parameters["client_secret"] = oauthOptions.clientSecret
        parameters["redirect_uri"] = oauthOptions.redirectURI.absoluteString
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset\(String.Encoding.utf8.charset)", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters.urlEncodedQuery.data(using: .utf8)
        
        print(parameters.urlEncodedQuery)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                completion(.failure(.tokenRequestError))
            }
            if let jsonData = data {
                do {
                    let decoder = JSONDecoder()
                    let tokenResponse = try decoder.decode(TokenResponse.self, from: jsonData)
                    
                    completion(.success(tokenResponse))
                } catch let error {
                    print(error)
                    
                    completion(.failure(.invalidTokenResponse))
                }
            }
        }
        
        task.resume()
    }
    
    private func refreshAccessToken(completion: (Result<TokenResponse, TokenError>) -> Void) {
        
    }
    
    
}
