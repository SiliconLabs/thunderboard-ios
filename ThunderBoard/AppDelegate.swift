//
//  AppDelegate.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    fileprivate var applicationPresenter: ApplicationPresenter?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        if let hockeyToken = ApplicationConfig.HockeyToken {
            BITHockeyManager.shared().configure(withIdentifier: hockeyToken)
            BITHockeyManager.shared().start()
        }

        let background = application.applicationState
        log.info("launchOptions=\(String(describing: launchOptions)) background=\(background.rawValue)")

        FirebaseConnectionMonitor.shared.checkAuth()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.tintColor = StyleColor.terbiumGreen
        self.applicationPresenter = ApplicationPresenter(window: self.window)
        self.applicationPresenter?.showDeviceSelection()
        self.window?.makeKeyAndVisible()

        return true
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        log.info("notification=\(notification) userInfo=\(String(describing: notification.userInfo))")
        handleLocalNotification(notification)
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        log.info("identifier=\(String(describing: identifier)) notification=\(notification) userInfo=\(String(describing: notification.userInfo))")
        handleLocalNotification(notification)
        completionHandler()
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        log.debug("notificationSettings: \(notificationSettings)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: UserNotificationSettingsUpdatedEvent), object: nil)
    }
    
    //MARK: - Private
    
    fileprivate func handleLocalNotification(_ notification: UILocalNotification) {
        log.info("notification=\(notification)")
        
        if let name = notification.userInfo?["deviceName"] as? String {
            log.info("Attempting to start connection to \(name)")
            self.applicationPresenter?.connectToNearbyDevice(name)
        }
        else {
            log.info("Failed to start direct connection - device name not found in notification payload")
        }
    }
}
