//
//  ClaimsTableViewDataSource.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/24/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import UIKit

class ClaimsDataSource: NSObject, UITableViewDataSource {
    var claims = [Claim]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return claims.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ClaimTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        let claim = claims[indexPath.row]
        cell.textLabel?.text = "\(claim.type): \(claim.value)"
        
        return cell
    }
}
