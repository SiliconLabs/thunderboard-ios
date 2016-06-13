//
//  DemoStreaming.swift
//  ThunderBoard
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
    func streamingEnabled(enabled: Bool)
    func streamStarting(longUrl: String)
    func streamStarted(shortUrl: String)
    func streamFailedToStart(error: NSError)
    func streamEncounteredError(error: NSError)
    func streamHeartbeat()
    func streamStopped()
}
