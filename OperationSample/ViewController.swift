//
//  ViewController.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/14/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import UIKit
import AuthenticationServices
import CryptoKit

class ViewController: UIViewController {
    
    private let oauthOptions: OAuthOptions = {
       return OAuthOptions(
        authority: URL(string: "https://demo.identityserver.io")!,
        clientId: "interactive.confidential.short",
        clientSecret: "secret",
        issuer: URL(string: "https://demo.identityserver.io")!,
        redirectURI: URL(string: "com.timmiller.operationsample://oauth-callback")!,
        scope: "api offline_access")
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //presentLogin()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presentLogin()
    }
    
    func presentLogin() {
        
        let codeVerifier = UUID().uuidString + UUID().uuidString
        print(codeVerifier)
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
            
            let scheme = "com.timmiller.operationsample"
            
            print(Thread.isMainThread)
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
                    self.retrieveTokens(code: code, codeVerifier: codeVerifier) { (result) in
                        switch result {
                        case let .failure(error):
                            print(error)
                        case let .success(tokenResponse):
                            print(tokenResponse.accessToken)
                            
                            
                        }
                    }
                }
            }
            
            //session.presentationContextProvider = self
            
            let activeScene = UIApplication.shared.connectedScenes.first(where: { (scene) -> Bool in
                if let sceneDelegate = scene.delegate as? SceneDelegate {
                    if let window = sceneDelegate.window, window.isKeyWindow {
                        return true
                    }
                }
                
                return false
                
            })
            
            if let activeScene = activeScene {
            
                if let sceneDelegate = activeScene.delegate as? SceneDelegate {
            
                    session.presentationContextProvider = sceneDelegate
                    
                    session.start()
                }
            }
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
            if let jsonData = data, let dataString = String(data: jsonData, encoding: .utf8) {
                print(dataString)
                
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

}

extension Dictionary {
    var urlEncodedQuery: String {
        var parts = [String]()
        
        for (key, value) in self {
            let keyString = "\(key)"
            let valueString = "\(value)"
            let query = "\(keyString)=\(valueString)"
            parts.append(query)
        }
        
        return parts.joined(separator: "&")
    }
}

extension String {
    var urlEncoded: String {
        let customAllowedSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
    }
    
    var urlQueryEncoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}

extension String.Encoding {
    var charset: String {
        let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.rawValue))
        
        return charset! as String
    }
}
