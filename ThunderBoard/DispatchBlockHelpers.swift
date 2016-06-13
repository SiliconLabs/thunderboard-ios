//
//  DispatchBlockHelpers.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

typealias DispatchBlock = ( () -> Void )
func delay(after: NSTimeInterval, run: DispatchBlock) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(after * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
        run()
    }
}

func dispatch_main_async(block: DispatchBlock) {
    NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
        block()
    }
}

func dispatch_main_sync(block: DispatchBlock) {
    dispatch_sync(dispatch_get_main_queue()) { () -> Void in
        block()
    }
}