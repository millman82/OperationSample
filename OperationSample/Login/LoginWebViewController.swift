//
//  LoginWebViewController.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/15/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import UIKit
import WebKit

class LoginWebViewController: UIViewController {
    
    let options: OAuthOptions
    
    override func loadView() {
        let webView = WKWebView()
        
        let currentLocale = Locale.current
        
        let authorizationUrl = options.authority + "connect/authorize"
        
        var request = URLRequest(url: URL(string: "https://demo.identityserver.io/connect/authorize")!)
        request.setValue(currentLocale.identifier, forHTTPHeaderField: "Accept-Language")
        webView.load(request)
        
        view = webView
    }
    
    required init?(oauthOptions options: OAuthOptions, coder: NSCoder) {
        self.options = options
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
