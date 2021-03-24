//
//  ClaimsTableViewController.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/24/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import UIKit

class ClaimsTableViewController: UITableViewController {
    
    var claimsService: ClaimsService?
    
    let claimsDataSource = ClaimsDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = claimsDataSource
        tableView.delegate = self
        
        tableView.tableFooterView = UIView()
        
        refreshControl = UIRefreshControl()
        
        refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        updateClaims()
    }
    
    func updateClaims() {
        guard let claimsService = claimsService else { return }
        
        print("Call 1")
        claimsService.retrieveClaims() { (result) in
            print("Handling call 1")
            switch result {
            case let .success(claims):
                self.claimsDataSource.claims = claims
                
                DispatchQueue.main.async {
                    self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                }
            case let .failure(error):
                print(error)
            }
            
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
        
//        print("Call 2")
//        claimsService.retrieveClaims() { (result) in
//            print("Handling call 2")
//            switch result {
//            case let .success(claims):
//                self.claimsDataSource.claims = claims
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
//                }
//            case let .failure(error):
//                print(error)
//            }
//
//            DispatchQueue.main.async {
//                self.refreshControl?.endRefreshing()
//            }
//        }
    }
    
    @objc private func handleRefresh() {
        print("handlingRefresh")
        
        updateClaims()
    }
}
