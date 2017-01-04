//
//  NavigationController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    var connectedDeviceView: ConnectedDeviceBarView!

    fileprivate let connectedDeviceBarHeight: CGFloat = 64
    fileprivate let connectionLostTitle = "Connection Lost"
    fileprivate let connectionDismiss   = "Dismiss"
    fileprivate func connectionLostMessage(_ deviceName: String) -> String {
        return "Connection with \(deviceName) has been lost"
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupConnectedDeviceBar()
        hideConnectedDeviceBar()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Public
    
    func showDeviceSelection() {
        dismissAlertsAndPopToRoot()
    }
    
    func showConnectedDevice() {
        self.showConnectedDeviceBar()
    }
    
    func updateConnectedDevice(_ name: String, power: PowerSource, firmwareVersion: String?) {
        self.updateDeviceInfo(name, power: power, firmware: firmwareVersion)
    }
    
    func hideConnectedDevice() {
        self.hideConnectedDeviceBar()
    }
    
    func showLostConnectionAlert(_ deviceName: String) {
        self.showConnectionFailedAlert(deviceName)
    }
    
    //MARK:- Internal Setup

    fileprivate func setupAppearance() {
        self.tb_setNavigationBarStyleForDemo(.transparent)
    }
    
    fileprivate func setupConnectedDeviceBar() {
        
        connectedDeviceView = ConnectedDeviceBarView()
        
        connectedDeviceView.backgroundColor = StyleColor.white
        connectedDeviceView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(connectedDeviceView)
        
        NSLayoutConstraint.activate([
            connectedDeviceView.heightAnchor.constraint(equalToConstant: connectedDeviceBarHeight),
            connectedDeviceView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            connectedDeviceView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            connectedDeviceView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    //MARK:- Internal
    
    fileprivate func hideConnectedDeviceBar() {
        self.connectedDeviceView.isHidden = true
    }
    
    fileprivate func showConnectedDeviceBar() {
        self.connectedDeviceView.isHidden = false
    }
    
    fileprivate func updateDeviceInfo(_ name: String, power: PowerSource, firmware: String?) {
        
        func updateBatteryLevel(_ level: Int) {
            var image: UIImage?
            switch level {
            case 0...10:
                image = UIImage(named: "icn_signal_0")
            case 11...25:
                image = UIImage(named: "icn_signal_25")
            case 26...50:
                image = UIImage(named: "icn_signal_50")
            case 51...75:
                image = UIImage(named: "icn_signal_75")
            default:
                image = UIImage(named: "icn_signal_100")
            }
            
            self.connectedDeviceView.batteryStatusImage.image = image
            self.connectedDeviceView.batteryStatusLabel.tb_setText("\(level)%", style: StyleText.numbers1)
        }
        
        self.connectedDeviceView.connectedToLabel.tb_setText("CONNECTED TO", style: StyleText.subtitle2)
        self.connectedDeviceView.deviceNameLabel.tb_setText(name, style: StyleText.deviceName2)
        
        switch power {
        case .unknown:
            self.connectedDeviceView.batteryStatusImage.image = UIImage(named: "icn_signal_unknown")
            self.connectedDeviceView.batteryStatusLabel.tb_setText(String.tb_placeholderText(), style: StyleText.numbers1)
            
        case .usb:
            self.connectedDeviceView.batteryStatusImage.image = UIImage(named: "icn_usb")
            self.connectedDeviceView.batteryStatusLabel.text = ""
            
        case .aa(let level):
            updateBatteryLevel(level)
            
        case .coinCell(let level):
            updateBatteryLevel(level)
            
        case .genericBattery(let level):
            updateBatteryLevel(level)
        }

        
        if let firmware = firmware {
            self.connectedDeviceView.firmwareVersionLabel.tb_setText(firmware, style: StyleText.subtitle2)
        }
        else {
            self.connectedDeviceView.firmwareVersionLabel.tb_setText(String.tb_placeholderText(), style: StyleText.subtitle2)
        }
    }
    
    fileprivate func showConnectionFailedAlert(_ deviceName: String) {

        let display = {
            let alert = UIAlertController(title: self.connectionLostTitle, message: self.connectionLostMessage(deviceName), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: self.connectionDismiss, style: .cancel, handler: { (alertAction: UIAlertAction) -> Void in
                self.popToRootViewController(animated: true)
            }))
            
            alert.view.tintColor = StyleColor.siliconGray
            self.present(alert, animated: true, completion: nil)
        }
        
        if let presented = self.viewControllers.last?.presentedViewController {
            presented.dismiss(animated: false, completion: { () -> Void in
                display()
            })
        }
        else {
            display()
        }
    }
    
    fileprivate func dismissAlertsAndPopToRoot() {
        // Is the current view controller presenting a view controller?
        if let presented = self.viewControllers.last?.presentedViewController {
            presented.dismiss(animated: false, completion: { () -> Void in
                self.popToRootViewController(animated: true)
            })
        }
        else {
            self.popToRootViewController(animated: true)
        }
    }
}

extension UINavigationController {
    
    enum NavigationBarStyle {
        case transparent
        case demoSelection
        case io
        case motion
        case environment
        case settings
    }
    
    func tb_setNavigationBarStyleForDemo(_ style: NavigationBarStyle) {
        
        self.navigationBar.isTranslucent = true
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = StyleColor.white

        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: StyleColor.white,
            NSFontAttributeName : StyleText.navBarTitle.font
        ]

        var image: UIImage?
        
        switch style {
        case .transparent:
            image = UIImage()   // clear
            
        case .demoSelection:
            image = UIImage.tb_imageWithColor(StyleColor.terbiumGreen, size: CGSize(width: 1, height: 1))
            
        case .io:
            image = UIImage.tb_imageWithColor(StyleColor.terbiumGreen, size: CGSize(width: 1, height: 1))
            
        case .motion:
            image = UIImage.tb_imageWithColor(StyleColor.terbiumGreen, size: CGSize(width: 1, height: 1))
            
        case .environment:
            image = UIImage.tb_imageWithColor(StyleColor.terbiumGreen, size: CGSize(width: 1, height: 1))
            
        case .settings:
            image = UIImage.tb_imageWithColor(StyleColor.terbiumGreen, size: CGSize(width: 1, height: 1))
        }

        self.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
    }
}
