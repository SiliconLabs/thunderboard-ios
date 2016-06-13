//
//  WeakTimer.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

typealias WeakTimerBlock = (() -> Void)

class WeakTimer : NSObject {
    
    private var timer: NSTimer?
    
    //MARK: -
    
    class func scheduledTimer(interval: NSTimeInterval, repeats: Bool, action: WeakTimerBlock) -> WeakTimer {
        let result = WeakTimer(interval: interval, repeats: repeats, action: action)
        result.start()
        return result
    }
    
    init(interval: NSTimeInterval, repeats: Bool, action: WeakTimerBlock) {
        super.init()
        let target = WeakTimerObserver(action: action)
        timer = NSTimer(timeInterval: interval, target: target, selector: Selector("timerFired"), userInfo: nil, repeats: repeats)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func start() {
        if let timer = timer {
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
    }
    
    func stop() {
        timer?.invalidate()
    }
    
    //MARK: - Internal
    
    private class WeakTimerObserver : NSObject {
        var actionBlock: WeakTimerBlock?
        
        init(action: WeakTimerBlock) {
            self.actionBlock = action
            super.init()
        }
        
        @objc func timerFired() {
            actionBlock?()
        }
    }
    
    
}