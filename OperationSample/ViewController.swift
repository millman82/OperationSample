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
    
    private let oauthOptions: OAuthOptions = {
        return AuthContext.shared.options
    }()

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var responseLabel: UILabel!
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        scrollView.addSubview(refreshControl)
        
        refreshControl.addTarget(self, action: #selector(ViewController.handleRefresh), for: UIControl.Event.valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let authService = OAuthService()
        authService.getToken(requestingViewController: self) { (token) in
            guard let apiEndpoint = URL(string: "https://demo.identityserver.io/api/test") else { return }
            var apiRequest = URLRequest(url: apiEndpoint)
            apiRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: apiRequest) { (data, response, error) in
                if let error = error {
                    print(error)
                }
                
                if let jsonData = data, let jsonString = String(data: jsonData, encoding: .utf8) {
                    
                    print(jsonString)
                    guard let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
                        let formattedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
                        let jsonString = String(data: formattedData, encoding: .utf8) else { return }
                    
                    DispatchQueue.main.async {
                        self.responseLabel.attributedText = NSAttributedString(string: jsonString)
                        self.responseLabel.sizeToFit()
                        
                        self.scrollView.contentSize = self.responseLabel.frame.size
                    }
                }
            }
            
            task.resume()
        }
    }
    
    @objc private func handleRefresh() {
        print("handlingRefresh")
        
        refreshControl.endRefreshing()
    }

}

extension ViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("here")
    }
}


