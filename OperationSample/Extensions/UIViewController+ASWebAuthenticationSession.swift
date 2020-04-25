//
//  UIViewController+ASWebAuthenticationSession.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/21/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import UIKit
import AuthenticationServices

extension UIViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
}
