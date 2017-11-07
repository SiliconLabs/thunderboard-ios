//
//  StreamingViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

enum StreamingBannerMode {
    case Disabled
    case NotStreaming
    case Streaming
    case ReconnectingFromStreaming
    case ReconnectingFromNotStreaming
    
    var message: String {
        switch self {
        case .Disabled:
            return "STREAMING DISABLED"
        case .NotStreaming:
            return "STREAM TO CLOUD"
        case .Streaming:
            return "STREAMING TO CLOUD"
        case .ReconnectingFromStreaming:
            return "RECONNECTING..."
        case .ReconnectingFromNotStreaming:
            return "RECONNECTING..."
        }
    }
}

@objc protocol StreamingViewControllerDelegate : class {
    func streamingButton(_ on: Bool)
    func sharingButtonTapped()
}

class StreamingViewController: UIViewController {

    @IBOutlet weak var streamingSwitch: UISwitch?
    @IBOutlet weak var statusMessage: StyledLabel?
    @IBOutlet weak var shareButton: UIButton?
    @IBOutlet weak var delegate: StreamingViewControllerDelegate?
    
    var streamingMode: StreamingBannerMode = .NotStreaming {
        
        didSet {
            updateStreamingModeDisplay()
        }
    }
    
    override var nibName: String? {
        get { return "StreamingViewController" }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StyleColor.gray
        self.statusMessage?.style = StyleText.streamingLabel
        self.streamingSwitch?.onTintColor = StyleColor.terbiumGreen
        self.streamingSwitch?.isOn = false
        updateStreamingModeDisplay()
    }
    
    //MARK: - Actions
    
    @IBAction func switchValueChanged(_ sender: AnyObject?) {
        if let on = streamingSwitch?.isOn {
            self.delegate?.streamingButton(on)
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: AnyObject?) {
        self.delegate?.sharingButtonTapped()
    }
    
    //MARK: - Private
    
    fileprivate func updateStreamingModeDisplay() {
        statusMessage?.text = streamingMode.message
        shareButton?.isHidden = !(streamingMode == .Streaming || streamingMode == .ReconnectingFromStreaming)
        streamingSwitch?.isEnabled = !(streamingMode == .Disabled || streamingMode == .ReconnectingFromNotStreaming)
    }
}
