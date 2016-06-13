//
//  SettingsNavigationController.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class SettingsNavigationController : UINavigationController {
    
    weak var notificationManager: NotificationManager?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tb_setNavigationBarStyleForDemo(.Settings)
        self.navigationBar.tintColor = StyleColor.white
        self.settingsViewController.notificationManager = notificationManager
    }
    
    var settingsViewController: SettingsViewController {
        get { return self.viewControllers[0] as! SettingsViewController }
    }
}