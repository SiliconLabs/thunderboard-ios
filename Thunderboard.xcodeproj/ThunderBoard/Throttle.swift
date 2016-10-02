//
//  Throttle.swift
//  Thunderboard
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

class Throttle {
    typealias ThrottleBlock = () -> ()
    private var queuedActions: Dictionary<String, ThrottleBlock> = [:]
    var interval: NSTimeInterval
    
    init(interval: NSTimeInterval) {
        self.interval = interval
    }
    
    func run(block: ThrottleBlock) {
        run("default", block: block)
    }
    
    func run(key: String, block: ThrottleBlock) {
        dispatch_main_async {
            if self.queuedActions[key] == nil {
                delay(self.interval) {
                    if let action = self.queuedActions.removeValueForKey(key) {
                        action()
                    }
                }
            }

            self.queuedActions[key] = block
        }
    }
}