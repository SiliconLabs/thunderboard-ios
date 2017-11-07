//
//  NotificationSettingsViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class NotificationSettingsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationSettingsInteractionOutput {
    
    fileprivate enum Sections: Int {
    case allowedDevices
    case otherDevices
    }
    
    @IBOutlet var tableView: UITableView?
    @IBOutlet var notificationsDescriptionLabel: StyledLabel?
    
    @IBOutlet var notificationsEnabledContainer: UIView?
    @IBOutlet var notificationsEnabledLabel: StyledLabel?
    @IBOutlet var notificationsEnabledSwitch: UISwitch?

    var interaction: NotificationSettingsInteraction?
    weak var notificationManager: NotificationManager?
    
    fileprivate var allowed = Array<NotificationDevice>()
    fileprivate var other = Array<NotificationDevice>()
    
    fileprivate let allowedDevicesTitle = "ALLOWED DEMO DEVICES"
    fileprivate let otherDevicesTitle   = "OTHER DEMO DEVICES"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupInteraction()
        
        tableView?.register(SettingsTableViewHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        self.title = "Beacon Notifications"
    }
    
    //MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section)! {
        case .allowedDevices:
            return allowed.count
        case .otherDevices:
            return other.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationSettingsDeviceCell") as! NotificationSettingsDeviceCell
        updateCell(cell, indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch Sections(rawValue: section)! {
        case .allowedDevices:
            return 40
        case .otherDevices:
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! SettingsTableViewHeader
        switch Sections(rawValue: section)! {
        case .allowedDevices:
            view.title = allowedDevicesTitle
        case .otherDevices:
            view.title = otherDevicesTitle
        }

        return view
    }
    
    //MARK: - Actions
    
    @IBAction func notificationSwitchChanged(_ sender: AnyObject?) {
        if let on = notificationsEnabledSwitch?.isOn {
            self.interaction?.enableNotifications(on)
        }
    }
    
    @IBAction func handleBack() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - NotificationSettingsInteractionOutput
    
    func notificationsEnabled(_ enabled: Bool) {
        notificationsEnabledSwitch?.setOn(enabled, animated: true)
        self.tableView?.isHidden = !enabled
    }
    
    func locationServicesNotAllowed() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Open Settings and enable Location in order to use beacons.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
        
        let settings = UIAlertAction(title: "Open Settings", style: .default) { (action: UIAlertAction) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        alert.addAction(settings)
        self.present(alert, animated: true, completion: nil)
    }
    
    func notificationsNotAllowed() {
        let alert = UIAlertController(title: "Notifications Disabled", message: "Open Settings and enable Notifications in order to use beacons.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
        
        let settings = UIAlertAction(title: "Open Settings", style: .default) { (action: UIAlertAction) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
        alert.addAction(settings)
        self.present(alert, animated: true, completion: nil)
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
    
    fileprivate func setupAppearance() {
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
    
    fileprivate func setupInteraction() {
        interaction = NotificationSettingsInteraction()
        interaction?.manager = self.notificationManager
        interaction?.output = self
    }

    fileprivate func updateCell(_ cell: NotificationSettingsDeviceCell, indexPath: IndexPath) {
        guard let tableView = self.tableView else {
            return
        }
        
        var device: NotificationDevice? = nil
        
        switch Sections(rawValue: indexPath.section)! {
        case .allowedDevices:
            device = allowed[indexPath.row]
            cell.setActionTitle("REMOVE")
            cell.deviceStatus?.text = device?.status.rawValue
            cell.actionHandler = { [weak self] in
                self?.interaction?.removeDevice(indexPath.row)
            }
        case .otherDevices:
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
