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
    fileprivate let firebaseUnavailableTitle = "Firebase Offline"
    fileprivate let firebaseUnavailableMessage = "Firebase is offline. Streaming is disabled."
    fileprivate let authFailTitle = "Streaming To Firebase Disabled"
    fileprivate let authFailMessage = "Unable to authenticate Firebase. Streaming is disabled."
    fileprivate let reconnectingTitle = "Reconnecting To Firebase"
    fileprivate let reconnectingMessage = "Firebase momentarily offline. Attempting to reconnect."
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "streamingSegue" {
            self.streamingViewController = segue.destination as? StreamingViewController
            self.streamingViewController?.delegate = self
            
            if streamingEnabled == false {
                self.streamingViewController?.streamingMode = .Disabled
                presentFirebaseUnavailableAlert()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StyleColor.lightGray
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(firebaseStatusDidChange),
                                               name: FirebaseConnectionMonitor.shared.statusChangedNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self,
                                                  name: FirebaseConnectionMonitor.shared.statusChangedNotification,
                                                  object: nil)
    }

    func firebaseStatusDidChange() {
        switch FirebaseConnectionMonitor.shared.isConnected {
        case true:
            streamingEnabled = true
            let newStreamingMode: StreamingBannerMode = self.streamingViewController?.streamingMode == .ReconnectingFromStreaming ? .Streaming : .NotStreaming
            self.streamingViewController?.streamingMode = newStreamingMode
        case false:
            streamingEnabled = false
            let newStreamingMode: StreamingBannerMode = self.streamingViewController?.streamingMode == .Streaming ? .ReconnectingFromStreaming : .ReconnectingFromNotStreaming
            self.streamingViewController?.streamingMode = newStreamingMode
            presentFirebaseUnavailableAlert(onViewLoad: false)
        }
    }
    
    private func presentFirebaseUnavailableAlert(onViewLoad: Bool = true) {
        var title: String
        var message: String
        
        if onViewLoad {
            switch FirebaseConnectionMonitor.shared.authenticationStatus {
            case .AuthSuccess:
                title = firebaseUnavailableTitle
                message = firebaseUnavailableMessage
            case .AuthFailed:
                title = authFailTitle
                message = authFailMessage
            }
        }
        else {
            title = reconnectingTitle
            message = reconnectingMessage
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.view.tintColor = StyleColor.siliconGray
        present(alert, animated: true, completion: nil)
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
        let newStreamingMode: StreamingBannerMode = self.streamingViewController?.streamingMode == .ReconnectingFromStreaming ? .ReconnectingFromNotStreaming : .NotStreaming
        self.streamingViewController?.streamingMode = newStreamingMode
    }
    
    func showStreamingError(_ error: NSError) {
        self.streamingViewController?.streamingMode = .ReconnectingFromStreaming
    }
    
    func streamOperational() {
        self.streamingViewController?.streamingMode = .Streaming
    }
}
