//
//  AppDelegate.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var applicationPresenter: ApplicationPresenter?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        if let hockeyToken = ApplicationConfig.HockeyToken {
            BITHockeyManager.sharedHockeyManager().configureWithIdentifier(hockeyToken)
            BITHockeyManager.sharedHockeyManager().startManager()
        }

        let background = application.applicationState
        log.info("launchOptions=\(launchOptions) background=\(background.rawValue)")

        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.applicationPresenter = ApplicationPresenter(window: self.window)
        self.applicationPresenter?.showDeviceSelection()
        self.window?.makeKeyAndVisible()

        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        log.info("notification=\(notification) userInfo=\(notification.userInfo)")
        handleLocalNotification(notification)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        log.info("identifier=\(identifier) notification=\(notification) userInfo=\(notification.userInfo)")
        handleLocalNotification(notification)
        completionHandler()
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        log.debug("notificationSettings: \(notificationSettings)")
        NSNotificationCenter.defaultCenter().postNotificationName(UserNotificationSettingsUpdatedEvent, object: nil)
    }
    
    //MARK: - Private
    
    private func handleLocalNotification(notification: UILocalNotification) {
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
