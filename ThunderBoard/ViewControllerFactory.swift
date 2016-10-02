//
//  ViewControllerFactory.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class ViewControllerFactory {
    
    var presenter: ApplicationPresenter?

    func deviceSelectionViewController(scanner: DeviceScanner, connector: DeviceConnection, settingsPresenter: SettingsPresenter) -> DeviceSelectionViewController {
        
        let deviceViewController = UIStoryboard(name: "DeviceSelection", bundle: nil).instantiateViewControllerWithIdentifier("DeviceSelectionViewController") as! DeviceSelectionViewController

        let interaction = DeviceSelectionInteraction(scanner: scanner, connector: connector, interactionOutput: deviceViewController)
        interaction.settingsPresenter = settingsPresenter
        deviceViewController.interaction = interaction
        
        return deviceViewController
    }

    func demoSelectionViewController(demoConfiguration: DemoConfiguration, demoPresenter: DemoPresenter, settingsPresenter: SettingsPresenter, historyPresenter: DemoHistoryPresenter, notificationManager: NotificationManager) -> DemoSelectionViewController {

        let demoViewController = UIStoryboard(name: "DemoSelection", bundle: nil).instantiateViewControllerWithIdentifier("DemoSelectionViewController") as! DemoSelectionViewController
        
        let interaction = DemoSelectionInteraction(demoConfiguration: demoConfiguration, output: demoViewController)
        interaction.demoPresenter = demoPresenter
        interaction.historyPresenter = historyPresenter
        interaction.settingsPresenter = settingsPresenter
        
        demoConfiguration.configurationDelegate = interaction
        demoViewController.interaction = interaction
        return demoViewController
    }

    func environmentDemoViewController(connection: EnvironmentDemoConnection) -> EnvironmentDemoViewController {
        
        let demoViewController = UIStoryboard(name: "EnvironmentDemoViewController", bundle: nil).instantiateViewControllerWithIdentifier("EnvironmentDemoViewController") as! EnvironmentDemoViewController
        
        let interaction = EnvironmentDemoInteraction(output: demoViewController, demoConnection: connection)
        interaction.streamingOutput = demoViewController
        interaction.streamSharePresenter = self.presenter
        
        let streaming = EnvironmentDemoStreamingConnection(device: connection.device, output: interaction)
        streaming.dataSource = interaction
        interaction.streamingConnection = streaming

        demoViewController.interaction = interaction
        demoViewController.streamingInteraction = interaction
        
        return demoViewController
    }
    
    func ioDemoViewController(connection: IoDemoConnection) -> IoDemoViewController {

        let demoViewController = UIStoryboard(name: "IoDemoViewController", bundle: nil).instantiateViewControllerWithIdentifier("IoDemoViewController") as! IoDemoViewController
        
        let interaction = IoDemoInteraction(output: demoViewController, demoConnection: connection)
        interaction.streamingOutput = demoViewController
        interaction.streamSharePresenter = self.presenter
        
        let streaming = IoDemoStreamingConnection(device: connection.device, output: interaction)
        streaming.dataSource = interaction
        interaction.streamingConnection = streaming

        demoViewController.interaction = interaction
        demoViewController.streamingInteraction = interaction

        return demoViewController
    }

    func motionCarDemoViewController(connection: MotionDemoConnection) -> MotionCarDemoViewController {
        
        let demoViewController = UIStoryboard(name: "MotionCarDemoViewController", bundle: nil).instantiateViewControllerWithIdentifier("MotionCarDemoViewController") as! MotionCarDemoViewController
        
        let interaction = MotionDemoInteraction(output: demoViewController, demoConnection: connection)
        interaction.streamingOutput = demoViewController
        interaction.streamSharePresenter = self.presenter

        let streaming = MotionDemoStreamingConnection(device: connection.device, output: interaction)
        streaming.dataSource = interaction
        interaction.streamingConnection = streaming
        
        demoViewController.interaction = interaction
        demoViewController.streamingInteraction = interaction
        
        return demoViewController
    }
    
    func motionBoardDemoViewController(connection: MotionDemoConnection) -> MotionBoardDemoViewController {
        
        let demoViewController = UIStoryboard(name: "MotionBoardDemoViewController", bundle: nil).instantiateViewControllerWithIdentifier("MotionBoardDemoViewController") as! MotionBoardDemoViewController
        
        let interaction = MotionDemoInteraction(output: demoViewController, demoConnection: connection)
        interaction.streamingOutput = demoViewController
        interaction.streamSharePresenter = self.presenter
        
        let streaming = MotionDemoStreamingConnection(device: connection.device, output: interaction)
        streaming.dataSource = interaction
        interaction.streamingConnection = streaming
        
        demoViewController.interaction = interaction
        demoViewController.streamingInteraction = interaction

        return demoViewController
    }
    
    func motionSenseBoardDemoViewController(connection: MotionDemoConnection) -> MotionSenseBoardDemoViewController {
        
        let demoViewController = UIStoryboard(name: "MotionSenseBoardDemoViewController", bundle: nil).instantiateViewControllerWithIdentifier("MotionSenseBoardDemoViewController") as! MotionSenseBoardDemoViewController
        
        let interaction = MotionDemoInteraction(output: demoViewController, demoConnection: connection)
        interaction.streamingOutput = demoViewController
        interaction.streamSharePresenter = self.presenter
        
        let streaming = MotionDemoStreamingConnection(device: connection.device, output: interaction)
        streaming.dataSource = interaction
        interaction.streamingConnection = streaming
        
        demoViewController.interaction = interaction
        demoViewController.streamingInteraction = interaction
        
        return demoViewController
    }

    func settingsViewController(notificationManager: NotificationManager) -> UIViewController {
        let settings = UIStoryboard(name: "SettingsViewController", bundle: nil).instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsNavigationController
        settings.notificationManager = notificationManager
        
        return settings
    }
}