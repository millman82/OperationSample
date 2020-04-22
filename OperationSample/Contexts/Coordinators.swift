//
//  Coordinators.swift
//  OperationSample
//
//  Created by Daniel Yount on 4/21/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

final class Coordinators {
    static var authentication = AuthenticationCoordinator()
}

class AuthenticationCoordinator {
    var authContext: AuthContext = {
        var plistURL = Bundle.main.url(forResource: "OAuthOptions", withExtension: "plist")!
        let data = try! Data(contentsOf: plistURL)
        
        let decoder = PropertyListDecoder()
        let options = try! decoder.decode(OAuthOptions.self, from: data)
        return AuthContext(oauthOptions: options)
    }()
}
