//
//  MainViewController.swift
//  OperationSample
//
//  Created by Daniel Yount on 4/21/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import UIKit
import Combine

extension Notification.Name {
    static let loginCredentialsNeeded = Notification.Name("login_credentials_needed")
}

/// Main View Controller should be the parent and base level entry point for
class MainViewController: UIViewController {
    
    private var disposables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.publisher(for: .loginCredentialsNeeded)
            .receive(on: RunLoop.main)
            .sink { _ in
                self.showLoginView()
        }
        .store(in: &disposables)
    }
    
    func unsubToAllNotifications() {
        for t in disposables { t.cancel() }
    }
    
}

// MARK: - Startup
extension MainViewController {
    func showStartupView() {
        /// instantiate startupVC then present
    }
}

// MARK: - Login
extension MainViewController {
    func showLoginView() { }
    func handleSignOut() { }
}
