//
//  LoginOperation.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/25/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

enum TokenError: Error {
    case tokenRequestError
    case invalidRefreshToken
    case invalidTokenResponse
}

class TokenOperation: AsyncOperation {
    typealias tokenCompletionBlock = (Result<TokenResponse, TokenError>) -> Void
    
    private let tokenEndpoint: URL
    private let parameters: [String:Any]
    private let completion: tokenCompletionBlock
    
    override func main() {
        if !isCancelled {
            issueTokenRequest(completion: completion)
        } else {
            finish()
        }
    }
    
    init(_ tokenEndpoint: URL, parameters: [String:Any], completion: @escaping tokenCompletionBlock) {
        self.tokenEndpoint = tokenEndpoint
        self.parameters = parameters
        self.completion = completion
    }
    
    private func issueTokenRequest(completion: @escaping tokenCompletionBlock) {
        var request = URLRequest(url: tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset\(String.Encoding.utf8.charset)", forHTTPHeaderField: "Content-Type")
        
        var requestParameters = self.parameters
        
        if let authorizationCode = AuthContext.shared.authorizationCode {
            requestParameters["code"] = authorizationCode
        }
        
        request.httpBody = requestParameters.urlEncodedQuery.data(using: .utf8)
        
        if !isCancelled {
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                defer {
                    self.finish()
                }
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
                
                AuthContext.shared.authorizationCode = nil
            }
            
            task.resume()
        } else {
            finish()
        }
    }
}
