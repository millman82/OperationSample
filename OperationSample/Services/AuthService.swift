//
//  AuthService.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/14/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import UIKit

protocol AuthService {
    func getToken(requestingViewController: UIViewController, completion: @escaping (String) -> Void)
}
