//
//  DemoInteraction.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import Foundation

protocol DemoStreamingInteraction {
    var streamingOutput: DemoStreamingInteractionOutput? { get }
    var streamingConnection: DemoStreamingConnection? { get }
    var streamSharePresenter: DemoStreamSharePresenter? { get }

    func startStreaming()
    func stopStreaming()
    func shareStream()
}

protocol DemoStreamingInteractionOutput : class {
    func streamingEnabled(enabled: Bool)
    func streamStarted()
    func streamStarting()
    func streamOperational()
    func streamStopped()
    func showStreamingError(error: NSError)
}

extension DemoStreamingInteraction where Self: DemoStreamingOutput  {
    
    //MARK: - DemoInteraction (Default Implementations)

    func startStreaming() {
        streamingConnection?.startStreaming()
    }
    
    func stopStreaming() {
        streamingConnection?.stopStreaming()
    }
    
    func shareStream() {
        guard let session = streamingConnection?.currentSession() else {
            return
        }
        
        streamSharePresenter?.shareDemoUrl(session.shortUrl)
    }
    
    //MARK: - DemoStreamingDelegate
    
    func streamingEnabled(enabled: Bool) {
        streamingOutput?.streamingEnabled(enabled)
    }
    
    func streamStarting(longUrl: String) {
        streamingOutput?.streamStarting()
    }
    
    func streamStarted(url: String) {
        streamingOutput?.streamStarted()
    }
    
    func streamFailedToStart(error: NSError) {
        streamingOutput?.streamStopped()
    }
    
    func streamStopped() {
        streamingOutput?.streamStopped()
    }
    
    func streamEncounteredError(error: NSError) {
        streamingOutput?.showStreamingError(error)
    }
    
    func streamHeartbeat() {
        streamingOutput?.streamOperational()
    }
    
}