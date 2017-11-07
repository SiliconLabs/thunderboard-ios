//
//  ViewControllerFactory.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class ViewControllerFactory {
    
    var presenter: ApplicationPresenter?

    func deviceSelectionViewController(_ scanner: DeviceScanner, connector: DeviceConnection, settingsPresenter: SettingsPresenter) -> DeviceSelectionViewController {
        
        let deviceViewController = UIStoryboard(name: "DeviceSelection", bundle: nil).instantiateViewController(withIdentifier: "DeviceSelectionViewController") as! DeviceSelectionViewController

        let interaction = DeviceSelectionInteraction(scanner: scanner, connector: connector, interactionOutput: deviceViewController)
        interaction.settingsPresenter = settingsPresenter
        deviceViewController.interaction = interaction
        
        return deviceViewController
    }

    func demoSelectionViewController(_ demoConfiguration: DemoConfiguration, demoPresenter: DemoPresenter, settingsPresenter: SettingsPresenter, historyPresenter: DemoHistoryPresenter, notificationManager: NotificationManager) -> DemoSelectionViewController {

        let demoViewController = UIStoryboard(name: "DemoSelection", bundle: nil).instantiateViewController(withIdentifier: "DemoSelectionViewController") as! DemoSelectionViewController
        
        let interaction = DemoSelectionInteraction(demoConfiguration: demoConfiguration, output: demoViewController)
        interaction.demoPresenter = demoPresenter
        interaction.historyPresenter = historyPresenter
        interaction.settingsPresenter = settingsPresenter
        
        demoConfiguration.configurationDelegate = interaction
        demoViewController.interaction = interaction
        return demoViewController
    }

    func environmentDemoViewController(_ connection: EnvironmentDemoConnection) -> EnvironmentDemoViewController {
        
        let demoViewController = UIStoryboard(name: "EnvironmentDemoViewController", bundle: nil).instantiateViewController(withIdentifier: "EnvironmentDemoViewController") as! EnvironmentDemoViewController
        
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
    
    func ioDemoViewController(_ connection: IoDemoConnection) -> IoDemoViewController {

        let demoViewController = UIStoryboard(name: "IoDemoViewController", bundle: nil).instantiateViewController(withIdentifier: "IoDemoViewController") as! IoDemoViewController
        
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

    func motionCarDemoViewController(_ connection: MotionDemoConnection) -> MotionCarDemoViewController {
        
        let demoViewController = UIStoryboard(name: "MotionCarDemoViewController", bundle: nil).instantiateViewController(withIdentifier: "MotionCarDemoViewController") as! MotionCarDemoViewController
        
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
    
    func motionBoardDemoViewController(_ connection: MotionDemoConnection) -> MotionBoardDemoViewController {
        
        let demoViewController = UIStoryboard(name: "MotionBoardDemoViewController", bundle: nil).instantiateViewController(withIdentifier: "MotionBoardDemoViewController") as! MotionBoardDemoViewController
        
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
    
    func motionSenseBoardDemoViewController(_ connection: MotionDemoConnection) -> MotionSenseBoardDemoViewController {
        
        let demoViewController = UIStoryboard(name: "MotionSenseBoardDemoViewController", bundle: nil).instantiateViewController(withIdentifier: "MotionSenseBoardDemoViewController") as! MotionSenseBoardDemoViewController
        
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

    func settingsViewController(_ notificationManager: NotificationManager) -> UIViewController {
        let settings = UIStoryboard(name: "SettingsViewController", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsNavigationController
        settings.notificationManager = notificationManager
        
        return settings
    }
}
