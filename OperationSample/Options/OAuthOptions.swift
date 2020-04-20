//
//  OAuthOptions.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/15/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

struct OAuthOptions {
    let authority: URL
    let clientId: String
    let clientSecret: String
    let issuer: URL
    let redirectURI: URL
    let scope: String
}
