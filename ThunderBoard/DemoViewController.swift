//
//  DemoViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit



class DemoViewController : UIViewController, DemoStreamingInteractionOutput, StreamingViewControllerDelegate {

    var streamingInteraction: DemoStreamingInteraction!
    fileprivate var streamingEnabled = false
    fileprivate var streamingViewController: StreamingViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "streamingSegue" {
            self.streamingViewController = segue.destination as? StreamingViewController
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
    
    func streamingButton(_ on: Bool) {
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
    
    func streamingEnabled(_ enabled: Bool) {
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
    
    func showStreamingError(_ error: NSError) {
        self.streamingViewController?.streamingMode = .Reconnecting
    }
    
    func streamOperational() {
        self.streamingViewController?.streamingMode = .Streaming
    }
}
