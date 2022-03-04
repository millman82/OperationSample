//
//  SceneDelegate+ASWebAuthenticationSession.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/25/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation
import AuthenticationServices

extension SceneDelegate: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.window ?? ASPresentationAnchor()
    }
}
