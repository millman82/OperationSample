//
//  Dictionary+URL.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/21/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

extension Dictionary {
    var urlEncodedQuery: String {
        var parts = [String]()
        
        for (key, value) in self {
            let keyString = "\(key)"
            let valueString = "\(value)"
            let query = "\(keyString)=\(valueString)"
            parts.append(query)
        }
        
        return parts.joined(separator: "&")
    }
}
