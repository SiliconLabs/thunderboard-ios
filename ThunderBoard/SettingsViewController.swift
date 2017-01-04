//
//  SettingsViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    fileprivate enum Sections: Int {
        case personalInfo
        case preferences
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
    fileprivate let settings = ThunderboardSettings()
    fileprivate let notificationsSegue           = "notificationsSegue"
    fileprivate let beaconEnabledText            = "ON"
    fileprivate let beaconDisabledText           = "OFF"
    fileprivate let personalInfoTitleText        = "PERSONAL INFO"
    fileprivate let preferencesTitleText         = "PREFERENCES"
    fileprivate let editLabelText                = "Edit"
    fileprivate let measurementsLabelText        = "Measurements"
    fileprivate let temperatureLabelText         = "Temperature"
    fileprivate let motionModelText              = "Motion Demo Model"
    fileprivate let beaconNotificationsLabelText = "Beacon Notifications"
    fileprivate let emptyNameText                = "Name"
    fileprivate let emptyTitleText               = "Title"
    fileprivate let emptyEmailText               = "Email"
    fileprivate let emptyPhoneText               = "Phone"
    fileprivate let versionText                  = "Version "
    fileprivate let copyrightText                = "| © Silicon Labs 2016"

    override func viewDidLoad() {
        setupAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        populatePersonalInfoFields()
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

        switch Sections(rawValue: section)! {
        case .personalInfo:
            setupSectionTitle(personalInfoTitleText, contentView: contentView)
            setupEditLabel(contentView)
        
        case .preferences:
            setupSectionTitle(preferencesTitleText, contentView: contentView)
        }
        
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
    
    func editTapped() {
        performSegue(withIdentifier: "editInfoSegue", sender: nil)
    }
    
    fileprivate func setupEditLabel(_ contentView: UIView) {
        let editView = StyledLabel()
        contentView.addSubview(editView)
        
        editView.tb_setText(editLabelText, style: StyleText.header)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editTapped))
        editView.addGestureRecognizer(tapGestureRecognizer)
        editView.isUserInteractionEnabled = true
        
        editView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(
            item: editView,
            attribute: .top,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .top,
            multiplier: 1,
            constant: 18)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: editView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .bottom,
            multiplier: 1,
            constant: -10)
        )
        contentView.addConstraint(NSLayoutConstraint(
            item: editView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .trailing,
            multiplier: 1,
            constant: -15)
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
    
    fileprivate func populatePersonalInfoFields() {
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
