//
//  ClaimsViewModel.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/24/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation
import UIKit

enum ClaimsApiError: Error {
    case invalidFormat
    case invalidURL
    case retreivalFailed
}

struct ClaimsService {
    private let authService: AuthService
    
    func retrieveClaims(completion: @escaping (Result<[Claim],ClaimsApiError>) -> Void) {
        authService.getToken() { (token) in
            guard let apiEndpoint = URL(string: "https://demo.identityserver.io/api/test") else {
                completion(.failure(.invalidURL))
                return
            }
            var apiRequest = URLRequest(url: apiEndpoint)
            apiRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: apiRequest) { (data, response, error) in
                if let error = error {
                    print(error)
                }
                    
                if let jsonData = data {
                    let decoder = JSONDecoder()
                    guard let claims = try? decoder.decode([Claim].self, from: jsonData) else {
                        completion(.failure(.invalidFormat))
                        return
                    }
                    
                    print("Number of claims: \(claims.count)")
                    
                    completion(.success(claims))
                }
            }
            
            task.resume()
        }
    }
    
    init(authService: AuthService) {
        self.authService = authService
    }
}
