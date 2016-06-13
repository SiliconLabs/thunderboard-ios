//
//  DeviceSelectionViewController.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class DeviceSelectionViewController: UIViewController, DeviceSelectionInteractionOutput, UITableViewDataSource, UITableViewDelegate {

    private let lookingForDevices               =   "Looking for Devices"
    private let connectionTimeoutTitle          =   "Connection Failed"
    private let connectionDismiss               =   "OK"
    private let noDevicesFoundString            =   "No Devices Found"
    private let bluetoothIsDisabledString       =   "Bluetooth is Disabled"
    
    private func connectionTimeoutMessage(deviceName: String) -> String {
        return "Unable to connect to the device \(deviceName)"
    }
    
    var presenter: DemoSelectionPresenter?

    @IBOutlet var backgroundImageTopLayout: NSLayoutConstraint?
    @IBOutlet var backgroundImageBottomLayout: NSLayoutConstraint?
    @IBOutlet var messagingContainerHeight: NSLayoutConstraint?
    @IBOutlet var deviceTableHeight: NSLayoutConstraint?
    @IBOutlet var taglineLabel: UILabel?
    @IBOutlet var poweredByLabel: UILabel?
    @IBOutlet var mmLogo: UIImageView?
    
    private let initialAnimationHold    = NSTimeInterval(1.3)
    private let initialAnimationFade    = NSTimeInterval(0.3)
    private let initialAnimationSlide   = NSTimeInterval(0.7)
    private let bottomSectionSmallHeight = 242
    private let bottomSectionSizeChangeThreshold = 4
    private let tableAnimationDuration = NSTimeInterval(0.3)
    
    @IBOutlet weak var logoImage: UIImageView?
    @IBOutlet weak var tableView: UITableView? {
        didSet {
            self.tableView?.backgroundColor = StyleColor.siliconGray
            self.tableView?.separatorStyle = .None
        }
    }
    @IBOutlet weak var messagingViewContainer: UIView? {
        didSet {
            self.messagingViewContainer?.backgroundColor = StyleColor.siliconGray
        }
    }
    
    @IBOutlet weak var userMessageLabel: UILabel?
    @IBOutlet weak var spinner: Spinner? {
        didSet {
            if let spinner = self.spinner {
                spinner.trackColor = StyleColor.footerGray
                spinner.lineColor = StyleColor.blue
                spinner.lineWidth = 2
            }
        }
    }
    @IBOutlet weak var bluetoothDisabledAlert: UIImageView?
    
    @IBAction func settingsButtonTapped() {
        interaction?.showSettings()
    }
    
    private let deviceNotFoundTimeoutInterval = 10.0
    
    var interaction: DeviceSelectionInteraction?
    weak var notificationManager: NotificationManager?
    
    private weak var currentAlert: UIAlertController?
    private var noDevicesTimeoutTimer: WeakTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StyleColor.siliconGray
        self.title = ""
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tb_setNavigationBarStyleForDemo(.Transparent)
        self.interaction?.startScanning()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.interaction?.stopScanning()
        stopTimeoutToFindDevices()
    }
    
    func startTimeoutToFindDevices() {
        log.debug("starting timer")
        noDevicesTimeoutTimer = WeakTimer.scheduledTimer(deviceNotFoundTimeoutInterval, repeats: false, action: { [weak self] () -> Void in
            if self?.interaction?.numberOfDevices() == 0 {
                self?.showNoDevicesFoundWarning()
            }
        })
    }
    
    func stopTimeoutToFindDevices() {
        log.debug("stopping timer")
        noDevicesTimeoutTimer = nil
    }
    
    //MARK: - UITableView DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numDevices = self.interaction?.numberOfDevices() else {
            return 0
        }
        
        return numDevices
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let display = (self.interaction?.deviceAtIndex(indexPath.row))!
        let cell = self.tableView?.dequeueReusableCellWithIdentifier("deviceCell") as! DeviceTableViewCell
        updateData(cell, device:display)
        cell.drawSeparator = indexPath.row > 0
        return cell
    }

    func updateData(cell: DeviceTableViewCell, device:DiscoveredDeviceDisplay) {
        cell.backgroundColor = StyleColor.siliconGray
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = StyleColor.footerGray
        cell.nameLabel.tb_setText(device.name, style: StyleText.deviceName)
        
        if device.connecting {
            cell.rssiImage.hidden = true
            cell.rssiLabel.hidden = true
            cell.connectingSpinner.hidden = false
            
            cell.connectingSpinner.trackColor = StyleColor.footerGray
            cell.connectingSpinner.lineColor = StyleColor.blue
            cell.connectingSpinner.startAnimating(StyleAnimations.spinnerDuration)
        }
        else {

            var signalImage: String = "icn_device_signal_0bar"
            if let rssi = device.RSSI {
                switch(rssi) {
                case -20 ..< 0:
                    signalImage = "icn_device_signal_5bar"
                case -40 ..< (-20):
                    signalImage = "icn_device_signal_4bar"
                case -60 ..< (-40):
                    signalImage = "icn_device_signal_3bar"
                case -80 ..< (-60):
                    signalImage = "icn_device_signal_2bar"
                case -90 ..< (-80):
                    signalImage = "icn_device_signal_1bar"
                default:
                    signalImage = "icn_device_signal_0bar"
                }

                cell.rssiLabel.tb_setText("\(rssi) dBm", style: StyleText.subtitle2)
                cell.rssiLabel.hidden = false
            }

            cell.rssiImage.image = UIImage(named: signalImage)
            cell.rssiImage.hidden = false

            cell.connectingSpinner.stopAnimating()
            cell.connectingSpinner.hidden = true
        }

    }

    //MARK: - UITableView Delegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectDevice(indexPath.row)
    }
    
    //MARK:- Internal
    
    private var viewState: DeviceListViewState = .Initial {
        didSet {
            switch viewState {
            case .Initial:
                self.messagingViewContainer?.hidden = true
                self.tableView?.hidden = true
                makeSpinnerVisible(false)

            case .BluetoothDisabled:
                self.messagingViewContainer?.hidden = false
                self.bluetoothDisabledAlert?.hidden = false
                self.tableView?.hidden = true
                makeSpinnerVisible(false)
                self.userMessageLabel?.tb_setText(bluetoothIsDisabledString, style: StyleText.deviceName3)
                animateInitialTransition()
                
            case .Searching:
                self.messagingViewContainer?.hidden = false
                self.bluetoothDisabledAlert?.hidden = true
                self.tableView?.hidden = true
                makeSpinnerVisible(true)
                self.userMessageLabel?.tb_setText(lookingForDevices, style: StyleText.deviceName3)
                animateInitialTransition()
                
            case .NoDevicesFound:
                self.messagingViewContainer?.hidden = false
                self.bluetoothDisabledAlert?.hidden = true
                self.tableView?.hidden = true
                makeSpinnerVisible(true)
                self.userMessageLabel?.tb_setText(noDevicesFoundString, style: StyleText.deviceName3)
                animateInitialTransition()

            case .DevicesFound:
                self.messagingViewContainer?.hidden = true
                self.tableView?.hidden = false
                makeSpinnerVisible(false)
                animateInitialTransition()
            }
        }
    }
    enum DeviceListViewState {
        case Initial
        case BluetoothDisabled
        case Searching
        case NoDevicesFound
        case DevicesFound
    }
    
    private func selectDevice(deviceIndex: Int) {
        self.interaction?.connectToDevice(deviceIndex)
    }
    
    private func showBluetoothDisabledWarning() {
        viewState = .BluetoothDisabled
    }
    
    private func hideBluetoothDisabledWarning() {
        viewState = .Searching
    }
    
    private func showNoDevicesFoundWarning() {
        viewState = .NoDevicesFound
    }
    
    private func hideNoDevicesFoundWarning() {
        viewState = .DevicesFound
    }
    
    private func makeSpinnerVisible(visible: Bool) {
        guard let spinner = self.spinner else {
            return
        }
        
        visible ? spinner.startAnimating(StyleAnimations.spinnerDuration) : spinner.stopAnimating()
        spinner.hidden = !visible
    }
    
    private func showDemoListWithConfiguration(configuration: DemoConfiguration) {
        self.dismissAllAlerts({
            self.presenter?.showDemoSelection(configuration)
        })
    }
    
    private func showConnectionTimedOutAlert(deviceName: String) {
        self.dismissAllAlerts({
            let alert = UIAlertController(title: self.connectionTimeoutTitle, message: self.connectionTimeoutMessage(deviceName), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: self.connectionDismiss, style: .Cancel, handler: nil))
            alert.view.tintColor = StyleColor.siliconGray
            self.presentViewController(alert, animated: true, completion: nil)
            
            self.currentAlert = alert
        })
        
        self.tableView?.reloadData()
    }
    
    private func showConnectionInProgress() {
        self.tableView?.reloadData()
    }
    
    private func dismissAllAlerts(completion: (() -> Void)?) {
        if let current = self.currentAlert {
            current.dismissViewControllerAnimated(false, completion: completion)
            self.currentAlert = nil
        }
        else {
            completion?()
        }
    }
    
    private var initialAnimationCompleted = false
    private func animateInitialTransition() {
        if initialAnimationCompleted == false {
            initialAnimationCompleted = true
            delay(initialAnimationHold) {
                NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                    UIView.animateWithDuration(self.initialAnimationFade, animations: {
                        self.taglineLabel?.alpha = 0.0
                        self.poweredByLabel?.alpha = 0.0
                        self.mmLogo?.alpha = 0.0
                        
                    }, completion: { (complete) -> Void in
                        if complete {
                            // animate into default state
                            self.view.layoutIfNeeded()
                            self.backgroundImageTopLayout?.constant = -1 * CGFloat(self.bottomSectionSmallHeight)
                            self.backgroundImageBottomLayout?.constant = CGFloat(self.bottomSectionSmallHeight)

                            UIView.animateWithDuration(self.initialAnimationSlide, animations: {
                                self.view.layoutIfNeeded()
                            })
                        }
                    })
                }
            }
        }
    }
    
    //MARK:- DeviceSelectionInteractionOutput
    
    // power
    func bleEnabled(enabled: Bool) {
        log.debug("enabed=\(enabled)")
        
        if enabled {
            hideBluetoothDisabledWarning()
        }
        else {
            showBluetoothDisabledWarning()
        }
    }
    
    // scanning

    func bleScanning(scanning: Bool) {
        log.debug("scanning=\(scanning)")
        
        if scanning {
            if self.interaction?.numberOfDevices() > 0 {
                viewState = .DevicesFound
            }
            else {
                viewState = .Searching
            }
            
            startTimeoutToFindDevices()
        }
        else {
            stopTimeoutToFindDevices()
        }
    }
    
    func bleScanningListUpdated() {
        tableView?.reloadData()
        
        if let count = self.interaction?.numberOfDevices() {
            
            if count > 0 {
                viewState = .DevicesFound
            }
            else {
                viewState = .Searching
            }
            
            startTimeoutToFindDevices()
            
            if count >= bottomSectionSizeChangeThreshold {
                let maxHeight = self.view.frame.size.height * 0.65
                self.deviceTableHeight?.constant = CGFloat(maxHeight)
                UIView.animateWithDuration(tableAnimationDuration) { () -> Void in
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func bleDeviceUpdated(device: DiscoveredDeviceDisplay, index: Int) {
        if let cell = tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! DeviceTableViewCell! {
            updateData(cell, device: device)
        }
    }
    
    func interactionShowConnectionInProgress(index: Int) {
        self.showConnectionInProgress()
    }
    
    func interactionShowConnectionTimedOut(deviceName: String) {
        self.showConnectionTimedOutAlert(deviceName)
    }
    
    func interactionShowConnectionDemos(configuration: DemoConfiguration) {
        self.showDemoListWithConfiguration(configuration)
    }

}
