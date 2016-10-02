//
//  UrlFactory.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

extension NSURL {
    static func tb_urlForDemoHistory(device: DeviceId) -> NSURL {
        let host = ApplicationConfig.FirebaseDemoHost
        return NSURL(string: "https://\(host)/#/\(device)/sessions")!
    }
}