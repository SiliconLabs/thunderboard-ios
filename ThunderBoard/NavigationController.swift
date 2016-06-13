//
//  NavigationController.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    var connectedDeviceView: ConnectedDeviceBarView!
    
    private let connectionLostTitle = "Connection Lost"
    private let connectionDismiss   = "Dismiss"
    private func connectionLostMessage(deviceName: String) -> String {
        return "Connection with \(deviceName) has been lost"
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK:- Public
    
    func showDeviceSelection() {
        dismissAlertsAndPopToRoot()
    }
    
    func showConnectedDevice() {
        self.showConnectedDeviceBar()
    }
    
    func updateConnectedDevice(name: String, battery: Int?, firmwareVersion: String?) {
        self.updateDeviceInfo(name, battery: battery, firmware: firmwareVersion)
    }
    
    func hideConnectedDevice() {
        self.hideConnectedDeviceBar()
    }
    
    func showLostConnectionAlert(deviceName: String) {
        self.showConnectionFailedAlert(deviceName)
    }
    
    //MARK:- Internal Setup

    private func setupAppearance() {
        self.tb_setNavigationBarStyleForDemo(.Transparent)
    }
    
    private func setupConnectedDeviceBar() {
        
        connectedDeviceView = ConnectedDeviceBarView.loadFromNib()
        
        connectedDeviceView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
        connectedDeviceView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(connectedDeviceView)
        
        // height
        self.view.addConstraint(NSLayoutConstraint(
            item: connectedDeviceView,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: 64)
        )
        
        // width
        self.view.addConstraint(NSLayoutConstraint(
            item: connectedDeviceView,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .Leading,
            multiplier: 1,
            constant: 0)
        )
        self.view.addConstraint(NSLayoutConstraint(
            item: connectedDeviceView,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .Trailing,
            multiplier: 1,
            constant: 0)
        )
        
        // anchor to bottom
        self.view.addConstraint(NSLayoutConstraint(
            item: connectedDeviceView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0))
    }
    
    //MARK:- Internal
    
    private func hideConnectedDeviceBar() {
        self.connectedDeviceView.hidden = true
    }
    
    private func showConnectedDeviceBar() {
        self.connectedDeviceView.hidden = false
    }
    
    private func updateDeviceInfo(name: String, battery: Int?, firmware: String?) {
        self.connectedDeviceView.backgroundColor = StyleColor.footerGray
        self.connectedDeviceView.connectedToLabel.tb_setText("CONNECTED TO", style: StyleText.subtitle2)
        self.connectedDeviceView.deviceNameLabel.tb_setText(name, style: StyleText.deviceName2)
        
        if let battery = battery {
            self.connectedDeviceView.batteryStatusLabel?.tb_setText("\(battery)%", style: StyleText.numbers1)

            var image: UIImage?
            switch battery {
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
        }
        else {
            self.connectedDeviceView.batteryStatusImage.image = UIImage(named: "icn_signal_unknown")
            self.connectedDeviceView.batteryStatusLabel?.tb_setText(String.tb_placeholderText(), style: StyleText.numbers1)
        }
        
        if let firmware = firmware {
            self.connectedDeviceView.firmwareVersionLabel.tb_setText(firmware, style: StyleText.subtitle2)
        }
        else {
            self.connectedDeviceView.firmwareVersionLabel.tb_setText(String.tb_placeholderText(), style: StyleText.subtitle2)
        }
    }
    
    private func showConnectionFailedAlert(deviceName: String) {

        let display = {
            let alert = UIAlertController(title: self.connectionLostTitle, message: self.connectionLostMessage(deviceName), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: self.connectionDismiss, style: .Cancel, handler: { (alertAction: UIAlertAction) -> Void in
                self.popToRootViewControllerAnimated(true)
            }))
            
            alert.view.tintColor = StyleColor.siliconGray
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        if let presented = self.viewControllers.last?.presentedViewController {
            presented.dismissViewControllerAnimated(false, completion: { () -> Void in
                display()
            })
        }
        else {
            display()
        }
    }
    
    private func dismissAlertsAndPopToRoot() {
        // Is the current view controller presenting a view controller?
        if let presented = self.viewControllers.last?.presentedViewController {
            presented.dismissViewControllerAnimated(false, completion: { () -> Void in
                self.popToRootViewControllerAnimated(true)
            })
        }
        else {
            self.popToRootViewControllerAnimated(true)
        }
    }
}

extension UINavigationController {
    
    enum NavigationBarStyle {
        case Transparent
        case IO
        case Motion
        case Environment
        case Settings
    }
    
    func tb_setNavigationBarStyleForDemo(style: NavigationBarStyle) {
        
        self.navigationBar.translucent = true
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = StyleColor.white

        self.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: StyleColor.white,
            NSFontAttributeName : StyleText.navBarTitle.font
        ]

        var image: UIImage?
        
        switch style {
        case .Transparent:
            image = UIImage()   // clear
            
        case .IO:
            image = UIImage.tb_imageWithColor(StyleColor.yellow, size: CGSizeMake(1, 1))
            
        case .Motion:
            image = UIImage.tb_imageWithColor(StyleColor.bromineOrange, size: CGSizeMake(1, 1))
            
        case .Environment:
            image = UIImage.tb_imageWithColor(StyleColor.terbiumGreen, size: CGSizeMake(1, 1))
            
        case .Settings:
            image = UIImage.tb_imageWithColor(StyleColor.blue, size: CGSizeMake(1, 1))
        }

        self.navigationBar.setBackgroundImage(image, forBarMetrics: UIBarMetrics.Default)
    }
}
