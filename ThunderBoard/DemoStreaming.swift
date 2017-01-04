//
//  DemoStreaming.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol DemoStreaming {
    func startStreaming()
    func stopStreaming()
    func currentSession() -> (shortUrl: String, connected: Bool)
}

protocol DemoStreamingOutput : class {
    func streamingEnabled(_ enabled: Bool)
    func streamStarting(_ longUrl: String)
    func streamStarted(_ shortUrl: String)
    func streamFailedToStart(_ error: NSError)
    func streamEncounteredError(_ error: NSError)
    func streamHeartbeat()
    func streamStopped()
}
