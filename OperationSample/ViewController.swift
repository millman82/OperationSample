//
//  ViewController.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/14/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import UIKit
import AuthenticationServices
import CryptoKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //presentLogin()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presentLogin()
    }
    
    func presentLogin() {
        
        let random = UUID().uuidString.filter({ $0 != "-" })
        print(random)
        if let strData = random.data(using: String.Encoding.utf8) {
            let sha256 = SHA256.hash(data: strData)
            
            var codeChallenge = ""
            for byte in sha256 {
                codeChallenge += String(format: "%02x", UInt8(byte))
            }
            
            guard var urlComponents = URLComponents(string: "https://demo.identityserver.io/connect/authorize") else { return }
            
            let csrf = UUID()
            
            urlComponents.queryItems = [
                URLQueryItem(name: "response_type", value: "code"),
                URLQueryItem(name: "client_id", value: "interactive.confidential.short"),
                URLQueryItem(name: "code_challenge", value: codeChallenge),
                URLQueryItem(name: "code_challenge_method", value: "S256"),
                URLQueryItem(name: "redirect_uri", value: "com.timmiller.operationsample://oauth-callback"),
                URLQueryItem(name: "scope", value: "api offline_access"),
                URLQueryItem(name: "state", value: csrf.uuidString)
            ]
            
            guard let authURL = urlComponents.url else { return }
            
            print(authURL)
            
            let scheme = "com.timmiller.operationsample"
            
            print(Thread.isMainThread)
            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { (callbackURL, error) in
                if let error = error {
                    print(error)
                }
                
                guard let callbackURL = callbackURL else { return }
                let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
                let code = queryItems?.filter({ $0.name == "code" }).first?.value
                
                print("code: \(code ?? "")")
            }
            
            //session.presentationContextProvider = self
            
            let activeScene = UIApplication.shared.connectedScenes.first(where: { (scene) -> Bool in
                if let sceneDelegate = scene.delegate as? SceneDelegate {
                    if let window = sceneDelegate.window, window.isKeyWindow {
                        return true
                    }
                }
                
                return false
                
            })
            
            if let activeScene = activeScene {
            
                if let sceneDelegate = activeScene.delegate as? SceneDelegate {
            
                    session.presentationContextProvider = sceneDelegate
                    
                    session.start()
                }
            }
        }
    }

}

//extension ViewController: ASWebAuthenticationPresentationContextProviding {
//    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
//        return view.window!
//    }
//}

