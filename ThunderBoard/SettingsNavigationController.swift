//
//  SettingsNavigationController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class SettingsNavigationController : UINavigationController {
    
    weak var notificationManager: NotificationManager?
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tb_setNavigationBarStyleForDemo(.settings)
        self.navigationBar.tintColor = StyleColor.white
        self.settingsViewController.notificationManager = notificationManager
    }
    
    var settingsViewController: SettingsViewController {
        get { return self.viewControllers[0] as! SettingsViewController }
    }
}
