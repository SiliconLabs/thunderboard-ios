//
//  SettingsViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    private enum Sections: Int {
        case PersonalInfo
        case Preferences
    }
    
    @IBOutlet weak var nameLabel: StyledLabel!
    @IBOutlet weak var titleLabel: StyledLabel!
    @IBOutlet weak var phoneLabel: StyledLabel!
    @IBOutlet weak var emailLabel: StyledLabel!

    @IBOutlet weak var measurementsLabel: StyledLabel!
    @IBOutlet weak var measurementsControl: UISegmentedControl!
    
    @IBOutlet weak var temperatureLabel: StyledLabel!
    @IBOutlet weak var temperatureControl: UISegmentedControl!
    
    @IBOutlet weak var motionModelLabel: StyledLabel!
    @IBOutlet weak var motionModelControl: UISegmentedControl!
    
    @IBOutlet weak var beaconNotificationsLabel: StyledLabel!
    @IBOutlet weak var beaconNotificationsStateLabel: StyledLabel!
    
    weak var notificationManager: NotificationManager?
    private let settings = ThunderboardSettings()
    private let notificationsSegue           = "notificationsSegue"
    private let beaconEnabledText            = "ON"
    private let beaconDisabledText           = "OFF"
    private let personalInfoTitleText        = "PERSONAL INFO"
    private let preferencesTitleText         = "PREFERENCES"
    private let editLabelText                = "Edit"
    private let measurementsLabelText        = "Measurements"
    private let temperatureLabelText         = "Temperature"
    private let motionModelText              = "Motion Demo Model"
    private let beaconNotificationsLabelText = "Beacon Notifications"
    private let emptyNameText                = "Name"
    private let emptyTitleText               = "Title"
    private let emptyEmailText               = "Email"
    private let emptyPhoneText               = "Phone"
    private let versionText                  = "Version "
    private let copyrightText                = "| © Silicon Labs 2016"

    override func viewDidLoad() {
        setupAppearance()
    }
    
    override func viewWillAppear(animated: Bool) {
        populatePersonalInfoFields()
        updateMeasurementsControl()
        updateTemperatureControl()
        updateMotionModelControl()
        updateBeaconNotificationsControl()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == notificationsSegue {
            if let notifications = segue.destinationViewController as? NotificationSettingsViewController {
                notifications.notificationManager = self.notificationManager
            }
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UITableViewHeaderFooterView()
        let contentView = headerView.contentView
        
        contentView.backgroundColor = StyleColor.lightGray

        switch Sections(rawValue: section)! {
        case .PersonalInfo:
            setupSectionTitle(personalInfoTitleText, contentView: contentView)
            setupEditLabel(contentView)
        
        case .Preferences:
            setupSectionTitle(preferencesTitleText, contentView: contentView)
        }
        
        return headerView
    }
    
    private func setupSectionTitle(title: String, contentView: UIView) {
        let titleView = StyledLabel()
        contentView.addSubview(titleView)
        titleView.tb_setText(title, style: StyleText.header)
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(
            item: titleView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Top,
            multiplier: 1,
            constant: 18)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: titleView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Bottom,
            multiplier: 1,
            constant: -10)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: titleView,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Leading,
            multiplier: 1,
            constant: 15)
        )
    }
    
    func editTapped() {
        performSegueWithIdentifier("editInfoSegue", sender: nil)
    }
    
    private func setupEditLabel(contentView: UIView) {
        let editView = StyledLabel()
        contentView.addSubview(editView)
        
        editView.tb_setText(editLabelText, style: StyleText.header)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editTapped))
        editView.addGestureRecognizer(tapGestureRecognizer)
        editView.userInteractionEnabled = true
        
        editView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(
            item: editView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Top,
            multiplier: 1,
            constant: 18)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: editView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Bottom,
            multiplier: 1,
            constant: -10)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: editView,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Trailing,
            multiplier: 1,
            constant: -15)
        )
        
    }
    
    private func setupFooter() {
        let footerView = UITableViewHeaderFooterView()
        let contentView = footerView.contentView
        let footerLabel = StyledLabel()
        footerLabel.textAlignment = NSTextAlignment.Center
        
        let version = UIApplication.sharedApplication().tb_version
        let build   = UIApplication.sharedApplication().tb_buildNumber
        let footerText  = "\(versionText) \(version) (\(build)) \(copyrightText)"
        footerLabel.tb_setText(footerText, style: StyleText.subtitle1)
        contentView.addSubview(footerLabel)
        tableView.tableFooterView = footerView
        
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(
            item:       footerLabel,
            attribute:  .CenterX,
            relatedBy:  .Equal,
            toItem:     contentView,
            attribute:  .CenterX,
            multiplier: 1,
            constant:   0)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item:       footerLabel,
            attribute:  .Top,
            relatedBy:  .Equal,
            toItem:     contentView,
            attribute:  .Bottom,
            multiplier: 1,
            constant:   0)
        )
        view.addConstraint(NSLayoutConstraint(
            item:       footerLabel,
            attribute:  .Height,
            relatedBy:  .Equal,
            toItem:      nil,
            attribute:  .NotAnAttribute,
            multiplier: 1,
            constant:   36)
        )
    }
    
    //MARK: action handlers
    
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func measurementsDidChange(sender: UISegmentedControl) {
        var newMeasurementsUnits: MeasurementUnits!
        switch measurementsControl.selectedSegmentIndex {
        case 0:
            newMeasurementsUnits = .Metric
        case 1:
            newMeasurementsUnits = .Imperial
        default:
            fatalError("Unsupported segment selected")
        }
        settings.measurement = newMeasurementsUnits
    }
    
    @IBAction func temperatureDidChange(sender: UISegmentedControl) {
        var newTemperatureUnits: TemperatureUnits!
        switch temperatureControl.selectedSegmentIndex {
        case 0:
            newTemperatureUnits = .Celsius
        case 1:
            newTemperatureUnits = .Fahrenheit
        default:
            fatalError("Unsupported segment selected")
        }
        settings.temperature = newTemperatureUnits
    }
    
    @IBAction func motionModelDidChange(sender: UISegmentedControl) {
        
        var newModel: MotionDemoModel!
        switch motionModelControl.selectedSegmentIndex {
        case 0:
            newModel = .Board
        case 1:
            newModel = .Car
        default:
            fatalError("Unsupported segment selected")
        }
        
        settings.motionDemoModel = newModel
    }
    
    // Private
    
    private func setupAppearance() {
        tableView.rowHeight          = UITableViewAutomaticDimension
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
    
    private func populatePersonalInfoFields() {
        if let name = settings.userName {
            nameLabel.tb_setText(name, style: StyleText.main1.tweakColorAlpha(1.0))
        } else {
            nameLabel.tb_setText(emptyNameText, style: StyleText.main1.tweakColorAlpha(0.5))
        }
        if let title = settings.userTitle {
            titleLabel.tb_setText(title, style: StyleText.main1.tweakColorAlpha(1.0))
        } else {
            titleLabel.tb_setText(emptyTitleText, style: StyleText.main1.tweakColorAlpha(0.5))
        }
        if let phone = settings.userPhone {
            phoneLabel.tb_setText(phone, style: StyleText.main1.tweakColorAlpha(1.0))
        } else {
            phoneLabel.tb_setText(emptyPhoneText, style: StyleText.main1.tweakColorAlpha(0.5))
        }
        if let email = settings.userEmail {
            emailLabel.tb_setText(email, style: StyleText.main1.tweakColorAlpha(1.0))
        } else {
            emailLabel.tb_setText(emptyEmailText, style: StyleText.main1.tweakColorAlpha(0.5))
        }
    }
    
    private func updateMeasurementsControl() {
        let measurementUnits = settings.measurement
        switch measurementUnits {
        case .Metric:
            measurementsControl.selectedSegmentIndex = 0
        case .Imperial:
            measurementsControl.selectedSegmentIndex = 1
        }
    }
    
    private func updateTemperatureControl() {
        let temperatureUnits = settings.temperature
        switch temperatureUnits {
        case .Celsius:
            temperatureControl.selectedSegmentIndex = 0
        case .Fahrenheit:
            temperatureControl.selectedSegmentIndex = 1
        }
    }
    
    private func updateMotionModelControl() {
        switch settings.motionDemoModel {
        case .Board:
            motionModelControl.selectedSegmentIndex = 0
        case .Car:
            motionModelControl.selectedSegmentIndex = 1
        }
    }
    
    private func updateBeaconNotificationsControl() {
        let enabled = settings.beaconNotifications
        let enabledText = enabled ? beaconEnabledText : beaconDisabledText
        beaconNotificationsStateLabel.tb_setText(enabledText, style: StyleText.header.tweakColor(color: StyleColor.mediumGray))
    }
}
