//
//  DeviceSelectionViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DeviceSelectionViewController: UIViewController, DeviceSelectionInteractionOutput, UITableViewDataSource, UITableViewDelegate {

    fileprivate let lookingForDevices               =   "Looking for Devices"
    fileprivate let connectionTimeoutTitle          =   "Connection Failed"
    fileprivate let connectionDismiss               =   "OK"
    fileprivate let noDevicesFoundString            =   "No Devices Found"
    fileprivate let bluetoothIsDisabledString       =   "Bluetooth is Disabled"
    
    fileprivate func connectionTimeoutMessage(_ deviceName: String) -> String {
        return "Unable to connect to the device \(deviceName)"
    }
    
    var presenter: DemoSelectionPresenter?

    @IBOutlet var messageContainerTopLayout: NSLayoutConstraint?
    
    @IBOutlet var deviceTableHeight: NSLayoutConstraint?
    @IBOutlet var mmLogo: UIImageView?
    
    fileprivate let initialAnimationHold    = TimeInterval(1.3)
    fileprivate let initialAnimationFade    = TimeInterval(0.3)
    fileprivate let initialAnimationSlide   = TimeInterval(0.7)
    fileprivate let bottomSectionSmallHeight = 242
    fileprivate let bottomSectionSizeChangeThreshold = 4
    fileprivate let tableAnimationDuration = TimeInterval(0.3)
    
    @IBOutlet weak var logoImage: UIImageView?
    @IBOutlet weak var tableView: UITableView? {
        didSet {
            self.tableView?.backgroundColor = StyleColor.white
            self.tableView?.separatorStyle = .none
        }
    }
    @IBOutlet weak var messagingViewContainer: UIView? {
        didSet {
            self.messagingViewContainer?.backgroundColor = StyleColor.white
        }
    }
    
    @IBOutlet weak var userMessageLabel: UILabel?
    @IBOutlet weak var spinner: Spinner? {
        didSet {
            self.spinner?.trackColor = StyleColor.lightGray
            self.spinner?.lineColor = StyleColor.terbiumGreen
            self.spinner?.lineWidth = 2
        }
    }
    @IBOutlet weak var bluetoothDisabledAlert: UIImageView?
    
    @IBAction func settingsButtonTapped() {
        interaction?.showSettings()
    }
    
    fileprivate let deviceNotFoundTimeoutInterval = 10.0
    
    var interaction: DeviceSelectionInteraction?
    weak var notificationManager: NotificationManager?
    
    fileprivate weak var currentAlert: UIAlertController?
    fileprivate var noDevicesTimeoutTimer: WeakTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = StyleColor.terbiumGreen
        self.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tb_setNavigationBarStyleForDemo(.transparent)
        self.interaction?.startScanning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numDevices = self.interaction?.numberOfDevices() else {
            return 0
        }
        
        return numDevices
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let display = (self.interaction?.deviceAtIndex(indexPath.row))!
        let cell = self.tableView?.dequeueReusableCell(withIdentifier: "deviceCell") as! DeviceTableViewCell
        updateData(cell, device:display)
        cell.drawSeparator = indexPath.row > 0
        return cell
    }

    func updateData(_ cell: DeviceTableViewCell, device:DiscoveredDeviceDisplay) {
        cell.backgroundColor = StyleColor.white
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = StyleColor.lightGray
        cell.nameLabel.tb_setText(device.name, style: StyleText.deviceName)
        
        if device.connecting {
            cell.rssiImage.isHidden = true
            cell.rssiLabel.isHidden = true
            cell.connectingSpinner.isHidden = false
            
            cell.connectingSpinner.trackColor = StyleColor.lightGray
            cell.connectingSpinner.lineColor = StyleColor.terbiumGreen
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
                cell.rssiLabel.isHidden = false
            }

            cell.rssiImage.image = UIImage(named: signalImage)
            cell.rssiImage.isHidden = false

            cell.connectingSpinner.stopAnimating()
            cell.connectingSpinner.isHidden = true
        }
    }

    //MARK: - UITableView Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectDevice(indexPath.row)
    }
    
    //MARK:- Internal
    
    fileprivate var viewState: DeviceListViewState = .initial {
        didSet {
            switch viewState {
            case .initial:
                self.messagingViewContainer?.isHidden = true
                self.tableView?.isHidden = true
                makeSpinnerVisible(false)

            case .bluetoothDisabled:
                self.messagingViewContainer?.isHidden = false
                self.bluetoothDisabledAlert?.isHidden = false
                self.tableView?.isHidden = true
                makeSpinnerVisible(false)
                self.userMessageLabel?.tb_setText(bluetoothIsDisabledString, style: StyleText.deviceListStatus)
                animateInitialTransition()
                
            case .searching:
                self.messagingViewContainer?.isHidden = false
                self.bluetoothDisabledAlert?.isHidden = true
                self.tableView?.isHidden = true
                makeSpinnerVisible(true)
                self.userMessageLabel?.tb_setText(lookingForDevices, style: StyleText.deviceListStatus)
                animateInitialTransition()
                
            case .noDevicesFound:
                self.messagingViewContainer?.isHidden = false
                self.bluetoothDisabledAlert?.isHidden = true
                self.tableView?.isHidden = true
                makeSpinnerVisible(true)
                self.userMessageLabel?.tb_setText(noDevicesFoundString, style: StyleText.deviceListStatus)
                animateInitialTransition()

            case .devicesFound:
                self.messagingViewContainer?.isHidden = true
                self.tableView?.isHidden = false
                makeSpinnerVisible(false)
                animateInitialTransition()
            }
        }
    }
    enum DeviceListViewState {
        case initial
        case bluetoothDisabled
        case searching
        case noDevicesFound
        case devicesFound
    }
    
    fileprivate func selectDevice(_ deviceIndex: Int) {
        self.interaction?.connectToDevice(deviceIndex)
    }
    
    fileprivate func showBluetoothDisabledWarning() {
        viewState = .bluetoothDisabled
    }
    
    fileprivate func hideBluetoothDisabledWarning() {
        viewState = .searching
    }
    
    fileprivate func showNoDevicesFoundWarning() {
        viewState = .noDevicesFound
    }
    
    fileprivate func hideNoDevicesFoundWarning() {
        viewState = .devicesFound
    }
    
    fileprivate func makeSpinnerVisible(_ visible: Bool) {
        visible ? spinner?.startAnimating(StyleAnimations.spinnerDuration) : spinner?.stopAnimating()
        spinner?.isHidden = !visible
    }
    
    fileprivate func showDemoListWithConfiguration(_ configuration: DemoConfiguration) {
        self.dismissAllAlerts({
            self.presenter?.showDemoSelection(configuration)
        })
    }
    
    fileprivate func showConnectionTimedOutAlert(_ deviceName: String) {
        self.dismissAllAlerts({
            let alert = UIAlertController(title: self.connectionTimeoutTitle, message: self.connectionTimeoutMessage(deviceName), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: self.connectionDismiss, style: .cancel, handler: nil))
            alert.view.tintColor = StyleColor.siliconGray
            self.present(alert, animated: true, completion: nil)
            
            self.currentAlert = alert
        })
        
        self.tableView?.reloadData()
    }
    
    fileprivate func showConnectionInProgress() {
        self.tableView?.reloadData()
    }
    
    fileprivate func dismissAllAlerts(_ completion: (() -> Void)?) {
        if let current = self.currentAlert {
            current.dismiss(animated: false, completion: completion)
            self.currentAlert = nil
        }
        else {
            completion?()
        }
    }
    
    fileprivate var initialAnimationCompleted = false
    fileprivate func animateInitialTransition() {
        if initialAnimationCompleted == false {
            initialAnimationCompleted = true
            delay(initialAnimationHold) {
                OperationQueue.main.addOperation { () -> Void in
                    UIView.animate(withDuration: self.initialAnimationFade, animations: {
                        self.mmLogo?.alpha = 0.0
                        
                    }, completion: { (complete) -> Void in
                        if complete {
                            // animate into default state
                            self.view.layoutIfNeeded()
                            
                            self.messageContainerTopLayout?.constant = -1 * CGFloat(self.bottomSectionSmallHeight)
                            
                            UIView.animate(withDuration: self.initialAnimationSlide, animations: {
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
    func bleEnabled(_ enabled: Bool) {
        log.debug("enabed=\(enabled)")
        
        if enabled {
            hideBluetoothDisabledWarning()
        }
        else {
            showBluetoothDisabledWarning()
        }
    }
    
    // scanning

    func bleScanning(_ scanning: Bool) {
        log.debug("scanning=\(scanning)")
        
        if scanning {
            if self.interaction?.numberOfDevices() > 0 {
                viewState = .devicesFound
            }
            else {
                viewState = .searching
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
                viewState = .devicesFound
            }
            else {
                viewState = .searching
            }
            
            startTimeoutToFindDevices()
            
            if count >= bottomSectionSizeChangeThreshold {
                let maxHeight = self.view.frame.size.height * 0.65
                self.deviceTableHeight?.constant = CGFloat(maxHeight)
                UIView.animate(withDuration: tableAnimationDuration, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                }) 
            }
        }
    }
    
    func bleDeviceUpdated(_ device: DiscoveredDeviceDisplay, index: Int) {
        if let cell = tableView?.cellForRow(at: IndexPath(row: index, section: 0)) as! DeviceTableViewCell! {
            updateData(cell, device: device)
        }
    }
    
    func interactionShowConnectionInProgress(_ index: Int) {
        self.showConnectionInProgress()
    }
    
    func interactionShowConnectionTimedOut(_ deviceName: String) {
        self.showConnectionTimedOutAlert(deviceName)
    }
    
    func interactionShowConnectionDemos(_ configuration: DemoConfiguration) {
        self.showDemoListWithConfiguration(configuration)
    }

}
