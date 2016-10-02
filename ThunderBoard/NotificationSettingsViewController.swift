//
//  NotificationSettingsViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class NotificationSettingsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationSettingsInteractionOutput {
    
    private enum Sections: Int {
    case AllowedDevices
    case OtherDevices
    }
    
    @IBOutlet var tableView: UITableView?
    @IBOutlet var notificationsDescriptionLabel: StyledLabel?
    
    @IBOutlet var notificationsEnabledContainer: UIView?
    @IBOutlet var notificationsEnabledLabel: StyledLabel?
    @IBOutlet var notificationsEnabledSwitch: UISwitch?

    var interaction: NotificationSettingsInteraction?
    weak var notificationManager: NotificationManager?
    
    private var allowed = Array<NotificationDevice>()
    private var other = Array<NotificationDevice>()
    
    private let allowedDevicesTitle = "ALLOWED DEMO DEVICES"
    private let otherDevicesTitle   = "OTHER DEMO DEVICES"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupInteraction()
        
        tableView?.registerClass(SettingsTableViewHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        self.title = "Beacon Notifications"
    }
    
    //MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section)! {
        case .AllowedDevices:
            return allowed.count
        case .OtherDevices:
            return other.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationSettingsDeviceCell") as! NotificationSettingsDeviceCell
        updateCell(cell, indexPath: indexPath)
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch Sections(rawValue: section)! {
        case .AllowedDevices:
            return 40
        case .OtherDevices:
            return 30
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! SettingsTableViewHeader
        switch Sections(rawValue: section)! {
        case .AllowedDevices:
            view.title = allowedDevicesTitle
        case .OtherDevices:
            view.title = otherDevicesTitle
        }

        return view
    }
    
    //MARK: - Actions
    
    @IBAction func notificationSwitchChanged(sender: AnyObject?) {
        if let on = notificationsEnabledSwitch?.on {
            self.interaction?.enableNotifications(on)
        }
    }
    
    @IBAction func handleBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - NotificationSettingsInteractionOutput
    
    func notificationsEnabled(enabled: Bool) {
        notificationsEnabledSwitch?.setOn(enabled, animated: true)
        self.tableView?.hidden = !enabled
    }
    
    func locationServicesNotAllowed() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Open Settings and enable Location in order to use beacons.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
        
        let settings = UIAlertAction(title: "Open Settings", style: .Default) { (action: UIAlertAction) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
        alert.addAction(settings)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func notificationsNotAllowed() {
        let alert = UIAlertController(title: "Notifications Disabled", message: "Open Settings and enable Notifications in order to use beacons.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
        
        let settings = UIAlertAction(title: "Open Settings", style: .Default) { (action: UIAlertAction) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
        alert.addAction(settings)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func notificationDevicesUpdated() {
        if let allowed = interaction?.allowedDevices() {
            self.allowed = allowed
        }
        if let others = interaction?.otherDevices() {
            self.other = others
        }
        
        self.tableView?.reloadData()
    }

    //MARK: - Private
    
    private func setupAppearance() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = StyleColor.lightGray
        
        self.tableView?.backgroundColor = StyleColor.lightGray
        self.tableView?.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)
        self.tableView?.preservesSuperviewLayoutMargins = false

        self.notificationsDescriptionLabel?.style = StyleText.note
        self.notificationsDescriptionLabel?.text = "You'll get a notification when an allowed Bluetooth demo device is on and in range. This helps demonstrate beaconing."
        
        self.notificationsEnabledContainer?.backgroundColor = StyleColor.white
        self.notificationsEnabledContainer?.tb_applyCommonDropShadow()
        self.notificationsEnabledLabel?.style = StyleText.main1
        self.notificationsEnabledLabel?.text = "Allow Beacon Notifications"
        self.notificationsEnabledSwitch?.onTintColor = StyleColor.terbiumGreen
    }
    
    private func setupInteraction() {
        interaction = NotificationSettingsInteraction()
        interaction?.manager = self.notificationManager
        interaction?.output = self
    }

    private func updateCell(cell: NotificationSettingsDeviceCell, indexPath: NSIndexPath) {
        guard let tableView = self.tableView else {
            return
        }
        
        var device: NotificationDevice? = nil
        
        switch Sections(rawValue: indexPath.section)! {
        case .AllowedDevices:
            device = allowed[indexPath.row]
            cell.setActionTitle("REMOVE")
            cell.deviceStatus?.text = device?.status.rawValue
            cell.actionHandler = { [weak self] in
                self?.interaction?.removeDevice(indexPath.row)
            }
        case .OtherDevices:
            device = other[indexPath.row]
            cell.setActionTitle("ALLOW")
            cell.deviceStatus?.text = ""
            cell.actionHandler = { [weak self] in
                self?.interaction?.allowDevice(indexPath.row)
            }
        }

        cell.drawSeparator = indexPath.row > 0
        cell.deviceName?.text = device?.name
        
        if tableView.tb_isLastCell(indexPath) {
            cell.tb_applyCommonDropShadow()
        }
        else {
            cell.tb_removeShadow()
        }
        
        cell.setNeedsLayout()
    }
}
