//
//  DiscoveryService.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/15/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

protocol DiscoveryService {
    func getDiscoveryInfo(oauthOptions options: OAuthOptions, completion: @escaping (DiscoveryInfo?) -> Void)
}
