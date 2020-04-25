//
//  OAuthViewController.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/25/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import AuthenticationServices
import UIKit

class OAuthViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    var globalPresentationAnchor: ASPresentationAnchor?
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return globalPresentationAnchor ?? ASPresentationAnchor()
    }
}
