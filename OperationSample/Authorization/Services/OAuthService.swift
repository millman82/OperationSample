//
//  OAuthService.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/26/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import AuthenticationServices
import Foundation

struct OAuthService: AuthService {
    let operationQueue = OperationQueue()
    
    private let globalPresentationAnchor: ASPresentationAnchor?
    
    private var oAuthOptions: OAuthOptions {
        get {
            return AuthContext.shared.options
        }
    }
    
    func getToken(completion: @escaping (String) -> Void) {
        let oAuthOperation = OAuthOperation(oAuthOptions: oAuthOptions, globalPresentationAnchor: globalPresentationAnchor) { (token) in
            if let token = token {
                completion(token)
            }
        }
        
        operationQueue.addOperation(oAuthOperation)
    }
    
    init(globalPresentationAnchor: ASPresentationAnchor?)
    {
        self.globalPresentationAnchor = globalPresentationAnchor
    }
}
