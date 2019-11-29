//
//  SettingsViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    fileprivate enum Sections: Int {
        case preferences
    }

    @IBOutlet weak var measurementsLabel: StyledLabel!
    @IBOutlet weak var measurementsControl: UISegmentedControl!
    
    @IBOutlet weak var temperatureLabel: StyledLabel!
    @IBOutlet weak var temperatureControl: UISegmentedControl!
    
    @IBOutlet weak var motionModelLabel: StyledLabel!
    @IBOutlet weak var motionModelControl: UISegmentedControl!
    
    @IBOutlet weak var beaconNotificationsLabel: StyledLabel!
    @IBOutlet weak var beaconNotificationsStateLabel: StyledLabel!
    
    weak var notificationManager: NotificationManager?
    fileprivate let settings = ThunderboardSettings()
    fileprivate let notificationsSegue           = "notificationsSegue"
    fileprivate let beaconEnabledText            = "ON"
    fileprivate let beaconDisabledText           = "OFF"
    fileprivate let preferencesTitleText         = "PREFERENCES"
    fileprivate let measurementsLabelText        = "Measurements"
    fileprivate let temperatureLabelText         = "Temperature"
    fileprivate let motionModelText              = "Motion Demo Model"
    fileprivate let beaconNotificationsLabelText = "Beacon Notifications"
    fileprivate let versionText                  = "Version "
    fileprivate let copyrightText                = "| © Silicon Labs 2016"

    override func viewDidLoad() {
        setupAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateMeasurementsControl()
        updateTemperatureControl()
        updateMotionModelControl()
        updateBeaconNotificationsControl()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == notificationsSegue {
            if let notifications = segue.destination as? NotificationSettingsViewController {
                notifications.notificationManager = self.notificationManager
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? SettingsViewCell else {
            fatalError("settings table cell subclass should be used")
        }
        
        cell.backgroundColor = StyleColor.white
        
        if tableView.tb_isLastCell(indexPath) {
            cell.drawBottomSeparator = false
            cell.tb_applyCommonDropShadow()
        }
        else {
            cell.drawBottomSeparator = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UITableViewHeaderFooterView()
        let contentView = headerView.contentView
        
        contentView.backgroundColor = StyleColor.lightGray

        setupSectionTitle(preferencesTitleText, contentView: contentView)
        
        return headerView
    }
    
    fileprivate func setupSectionTitle(_ title: String, contentView: UIView) {
        let titleView = StyledLabel()
        contentView.addSubview(titleView)
        titleView.tb_setText(title, style: StyleText.header)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(
            item: titleView,
            attribute: .top,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .top,
            multiplier: 1,
            constant: 18)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: titleView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .bottom,
            multiplier: 1,
            constant: -10)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: titleView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .leading,
            multiplier: 1,
            constant: 15)
        )
    }

    fileprivate func setupFooter() {
        let footerView = UITableViewHeaderFooterView()
        let contentView = footerView.contentView
        let footerLabel = StyledLabel()
        footerLabel.textAlignment = NSTextAlignment.center
        
        let version = UIApplication.shared.tb_version
        let build   = UIApplication.shared.tb_buildNumber
        let footerText  = "\(versionText) \(version) (\(build)) \(copyrightText)"
        footerLabel.tb_setText(footerText, style: StyleText.subtitle1)
        contentView.addSubview(footerLabel)
        tableView.tableFooterView = footerView
        
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(
            item:       footerLabel,
            attribute:  .centerX,
            relatedBy:  .equal,
            toItem:     contentView,
            attribute:  .centerX,
            multiplier: 1,
            constant:   0)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item:       footerLabel,
            attribute:  .top,
            relatedBy:  .equal,
            toItem:     contentView,
            attribute:  .bottom,
            multiplier: 1,
            constant:   0)
        )
        view.addConstraint(NSLayoutConstraint(
            item:       footerLabel,
            attribute:  .height,
            relatedBy:  .equal,
            toItem:      nil,
            attribute:  .notAnAttribute,
            multiplier: 1,
            constant:   36)
        )
    }
    
    //MARK: action handlers
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func measurementsDidChange(_ sender: UISegmentedControl) {
        var newMeasurementsUnits: MeasurementUnits!
        switch measurementsControl.selectedSegmentIndex {
        case 0:
            newMeasurementsUnits = .metric
        case 1:
            newMeasurementsUnits = .imperial
        default:
            fatalError("Unsupported segment selected")
        }
        settings.measurement = newMeasurementsUnits
    }
    
    @IBAction func temperatureDidChange(_ sender: UISegmentedControl) {
        var newTemperatureUnits: TemperatureUnits!
        switch temperatureControl.selectedSegmentIndex {
        case 0:
            newTemperatureUnits = .celsius
        case 1:
            newTemperatureUnits = .fahrenheit
        default:
            fatalError("Unsupported segment selected")
        }
        settings.temperature = newTemperatureUnits
    }
    
    @IBAction func motionModelDidChange(_ sender: UISegmentedControl) {
        
        var newModel: MotionDemoModel!
        switch motionModelControl.selectedSegmentIndex {
        case 0:
            newModel = .board
        case 1:
            newModel = .car
        default:
            fatalError("Unsupported segment selected")
        }
        
        settings.motionDemoModel = newModel
    }
    
    // Private
    
    fileprivate func setupAppearance() {
        tableView.rowHeight          = UITableView.automaticDimension
        tableView.estimatedRowHeight = 42
        
        automaticallyAdjustsScrollViewInsets = true
        view.backgroundColor = StyleColor.lightGray
        tableView?.backgroundColor = StyleColor.lightGray

        measurementsLabel.tb_setText(measurementsLabelText, style: StyleText.main1)
        temperatureLabel.tb_setText(temperatureLabelText, style: StyleText.main1)
        motionModelLabel.tb_setText(motionModelText, style: StyleText.main1)
        beaconNotificationsLabel.tb_setText(beaconNotificationsLabelText, style: StyleText.main1)
        beaconNotificationsStateLabel.style = StyleText.main1
        
        measurementsControl.tintColor = StyleColor.terbiumGreen
        temperatureControl.tintColor = StyleColor.terbiumGreen
        motionModelControl.tintColor = StyleColor.terbiumGreen
        
        setupFooter()
    }

    fileprivate func updateMeasurementsControl() {
        let measurementUnits = settings.measurement
        switch measurementUnits {
        case .metric:
            measurementsControl.selectedSegmentIndex = 0
        case .imperial:
            measurementsControl.selectedSegmentIndex = 1
        }
    }
    
    fileprivate func updateTemperatureControl() {
        let temperatureUnits = settings.temperature
        switch temperatureUnits {
        case .celsius:
            temperatureControl.selectedSegmentIndex = 0
        case .fahrenheit:
            temperatureControl.selectedSegmentIndex = 1
        }
    }
    
    fileprivate func updateMotionModelControl() {
        switch settings.motionDemoModel {
        case .board:
            motionModelControl.selectedSegmentIndex = 0
        case .car:
            motionModelControl.selectedSegmentIndex = 1
        }
    }
    
    fileprivate func updateBeaconNotificationsControl() {
        let enabled = settings.beaconNotifications
        let enabledText = enabled ? beaconEnabledText : beaconDisabledText
        beaconNotificationsStateLabel.tb_setText(enabledText, style: StyleText.header.tweakColor(color: StyleColor.mediumGray))
    }
}
