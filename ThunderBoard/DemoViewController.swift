//
//  DemoViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit



class DemoViewController : UIViewController, DemoStreamingInteractionOutput, StreamingViewControllerDelegate {

    var streamingInteraction: DemoStreamingInteraction!
    private var streamingEnabled = false
    private var streamingViewController: StreamingViewController?
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "streamingSegue" {
            self.streamingViewController = segue.destinationViewController as? StreamingViewController
            self.streamingViewController?.delegate = self
            
            if streamingEnabled == false {
                self.streamingViewController?.streamingMode = .Disabled
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StyleColor.lightGray
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    //MARK: - StreamingViewControllerDelegate
    
    func streamingButton(on: Bool) {
        if on {
            streamingInteraction.startStreaming()
        }
        else {
            streamingInteraction.stopStreaming()
        }
    }
    
    func sharingButtonTapped() {
        streamingInteraction?.shareStream()
    }
    
    //MARK: - DemoInteractionOutput
    
    func streamingEnabled(enabled: Bool) {
        // make a note of streaming mode, since segue will 
        // be performed after this function is called
        streamingEnabled = enabled
    }

    func streamStarting() {
        self.streamingViewController?.streamingMode = .Streaming
    }
    
    func streamStarted() {
        self.streamingViewController?.streamingMode = .Streaming
    }
    
    func streamStopped() {
        self.streamingViewController?.streamingMode = .NotStreaming
    }
    
    func showStreamingError(error: NSError) {
        self.streamingViewController?.streamingMode = .Reconnecting
    }
    
    func streamOperational() {
        self.streamingViewController?.streamingMode = .Streaming
    }
}
