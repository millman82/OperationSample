//
//  Operation.swift
//  OperationSample
//
//  Created by Timothy Miller on 4/25/20.
//  Copyright © 2020 Timothy Miller. All rights reserved.
//

import Foundation

class Operation: Foundation.Operation {
    
    // use the KVO mechanism to indicate that changes to "state" affect other properties as well
    class func keyPathsForValuesAffectingIsReady() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
    class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
    // MARK: State
    
    fileprivate enum State: Int, Comparable {
        case ready
        case executing
        case finished
        
        func canTransitionToState(_ target: State) -> Bool {
            switch (self, target) {
            case (.ready, .executing):
                return true
            case (.ready, .finished):
                return true
            case (.executing, .finished):
                return true
            default:
                return false
            }
        }
    }
    
    fileprivate var _state = State.ready
    
    fileprivate let stateLock = NSLock()
    
    fileprivate var state: State {
        get {
            stateLock.lock()
            let state = _state
            stateLock.unlock()
            return state
        }
        set(newState) {
            willChangeValue(forKey: "state")
            
            stateLock.lock()
            guard _state != .finished else {
                stateLock.unlock()
                return
            }
            
            assert(_state.canTransitionToState(newState), "Performing invalid state transition.")
            _state = newState
            stateLock.unlock()
            
            didChangeValue(forKey: "state")
        }
    }
    
    override var isReady: Bool {
        if state == .ready {
            return super.isReady || isCancelled
        }
        
        return false
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    // MARK: Execution and Cancellation
    
    override final func start() {
        super.start()
        
        if isCancelled {
            finish()
        }
    }
    
    func execute() {
        print("\(type(of: self)) must override `execute()`.")
        
        finish()
    }
    
    override final func main() {
        assert(state == .ready, "This operation must be performed on an operation queue.")
        
        if !isCancelled {
            state = .executing
            
            execute()
        } else {
            finish()
        }
    }
    
    final func finish() {
        state = .finished
    }
}

private func <(lhs: Operation.State, rhs: Operation.State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

private func ==(lhs: Operation.State, rhs: Operation.State) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
