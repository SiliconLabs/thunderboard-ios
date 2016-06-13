//
//  AsyncOperation.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

//  Inspired by ConcurrentOperation.swift
//  https://gist.github.com/calebd/93fa347397cec5f88233

import UIKit

typealias AsyncOperationBlock = ((AsyncOperation) -> Void)

class AsyncOperation: NSOperation {

    var operationBlock: AsyncOperationBlock?
    
    init(block: AsyncOperationBlock) {
        super.init()
        self.operationBlock = block
    }
    
    private var state = OperationState.Ready {
        willSet {
            willChangeValueForKey(newValue.keyPath())
            willChangeValueForKey(state.keyPath())
        }
        didSet {
            didChangeValueForKey(oldValue.keyPath())
            didChangeValueForKey(state.keyPath())
        }
    }
    private enum OperationState {
        case Ready, Executing, Finished
        func keyPath() -> String {
            switch self {
            case .Ready:     return "isReady"
            case .Executing: return "isExecuting"
            case .Finished:  return "isFinished"
            }
        }
    }
    
    //MARK: - Public
    
    func done() {
        state = .Finished
    }

    //MARK:- Overrides
    
    override var asynchronous: Bool {
        return true
    }
    
    override var ready: Bool {
        return super.ready && state == .Ready
    }
    
    override var executing: Bool {
        return state == .Executing
    }
    
    override var finished: Bool {
        return state == .Finished
    }
    
    override func start() {
        state = .Executing
        operationBlock?(self)
    }
}

extension NSOperationQueue {    
    func tb_addAsyncOperationBlock(block: AsyncOperationBlock) -> AsyncOperation {
        let operation = AsyncOperation(block: block)
        self.addOperation(operation)
        return operation
    }
    
    func tb_addAsyncOperationBlock(name: String, block: AsyncOperationBlock) -> AsyncOperation {
        let operation = self.tb_addAsyncOperationBlock(block)
        operation.name = name
        return operation
    }
}
