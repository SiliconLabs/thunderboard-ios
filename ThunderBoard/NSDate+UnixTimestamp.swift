//
//  NSDate+UnixTimestamp.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

extension Date {
    
    static var tb_currentTimestamp: Int64 {
        get {
            var time:timeval = timeval(tv_sec: 0, tv_usec: 0)
            gettimeofday(&time, nil)
            return (Int64(time.tv_sec) * 1000) + (Int64(time.tv_usec) / 1000)
        }
    }
    
}
