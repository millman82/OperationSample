//
//  AsyncOperation.swift
//  OperationSample
//
//  Created by Timothy Miller on 3/22/21.
//  Copyright © 2021 Timothy Miller. All rights reserved.
//

import Foundation

extension AsyncOperation {
    fileprivate enum State: String {
        case isReady, isExecuting, isFinished
    }
}

class AsyncOperation: Operation {
    
    override var isAsynchronous: Bool {
        true
    }
    
    private var state: State = .isReady {
        willSet {
            willChangeValue(forKey: state.rawValue)
            willChangeValue(forKey: newValue.rawValue)
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }
    
    override var isReady: Bool {
        (super.isReady && state == .isReady) || isCancelled
    }
    
    override var isExecuting: Bool {
        state == .isExecuting
    }
    
    override var isFinished: Bool {
        state == .isFinished
    }
    
    override func start() {
        if isCancelled {
            state = .isFinished
            return
        }
        
        state = .isExecuting
        main()
    }
    
    override func cancel() {
        finish()
    }
    
    func finish() {
        state = .isFinished
    }
}
