//
//  StreamingViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

enum StreamingBannerMode : String {
    case Disabled       = "STREAMING DISABLED"
    case NotStreaming   = "STREAM TO CLOUD"
    case Streaming      = "STREAMING TO CLOUD"
    case Reconnecting   = "RECONNECTING..."
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
        statusMessage?.text = streamingMode.rawValue
        
        switch streamingMode {
        case .Disabled:
            shareButton?.isEnabled = false
            streamingSwitch?.isEnabled = false
            streamingSwitch?.setOn(false, animated: true)
            shareButton?.isHidden = true
            
        case .NotStreaming:
            shareButton?.isHidden = true
            streamingSwitch?.setOn(false, animated: true)
            
        case .Streaming:
            shareButton?.isHidden = false
            
        case .Reconnecting:
            shareButton?.isHidden = false
        }
    }
}
