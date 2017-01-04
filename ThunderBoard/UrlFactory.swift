//
//  UrlFactory.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

extension URL {
    static func tb_urlForDemoHistory(_ device: DeviceId) -> URL {
        let host = ApplicationConfig.FirebaseDemoHost
        return URL(string: "https://\(host)/#/\(device)/sessions")!
    }
}
