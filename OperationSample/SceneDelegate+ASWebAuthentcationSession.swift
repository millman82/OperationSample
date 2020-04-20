//
//  SceneDelegate+ASWebAuthentcationSession.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/20/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import UIKit
import AuthenticationServices

extension SceneDelegate: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return window!
    }
}
