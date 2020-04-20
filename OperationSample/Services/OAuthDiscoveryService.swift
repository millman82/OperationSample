//
//  DiscoveryService.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/15/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

enum DiscoveryError: Error {
    case invalidJSONData
}

class OAuthDiscoveryService: DiscoveryService {
    private static let discoveryPath = ".well-known/openid-configuration"
    
    private static let cache = NSCache<NSString, DiscoveryInfo>()
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func getDiscoveryInfo(oauthOptions options: OAuthOptions, completion: @escaping (DiscoveryInfo?) -> Void) {
        if let cached = OAuthDiscoveryService.cache.object(forKey: options.authority.absoluteString as NSString) {
            completion(cached)
        }
        
        let discoveryEndpoint = options.authority.absoluteString + OAuthDiscoveryService.discoveryPath
        
        let request = URLRequest(url: URL(string: discoveryEndpoint)!)
        
        executeDiscoveryRequest(request) { (discoveryInfo) in
            guard let discoveryInfo = discoveryInfo else {
                completion(nil)
                return
            }
            
            OAuthDiscoveryService.cache.setObject(discoveryInfo, forKey: options.authority.absoluteString as NSString)
            completion(discoveryInfo)
        }
    }
    
    private func executeDiscoveryRequest(_ request: URLRequest, completion: @escaping (DiscoveryInfo?) -> Void)
    {
        let task = session.dataTask(with: request) { (data, response, error) in
            self.processDiscoveryResponse(data: data, error: error) { result in
                switch result {
                case let .success(discoveryInfo):
                    completion(discoveryInfo)
                case .failure:
                    print("failed to retreive discovery info.")
                }
            }
        }
        task.resume()
    }
    
    private func processDiscoveryResponse(data: Data?, error: Error?, completion: @escaping (Result<DiscoveryInfo, Error>) -> Void) {
        guard let jsonData = data else {
            completion(.failure(error!))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let discoveryInfo = try decoder.decode(DiscoveryInfo.self, from: jsonData)
            
            if discoveryInfo.issuer == "" || discoveryInfo.authorizationEndpoint == "" || discoveryInfo.tokenEndpoint == "" ||
                discoveryInfo.userInfoEndpoint == "" {
                completion(.failure(DiscoveryError.invalidJSONData))
            }
            
            completion(.success(discoveryInfo))
        } catch let error {
            completion(.failure(error))
        }
    }
}
