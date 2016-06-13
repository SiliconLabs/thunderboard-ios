//
//  ConnectedDeviceBarView.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class ConnectedDeviceBarView: UIView {
    @IBOutlet weak var connectedToLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var batteryStatusLabel: UILabel!
    @IBOutlet weak var batteryStatusImage: UIImageView!
    @IBOutlet weak var firmwareVersionLabel: UILabel!
}

extension ConnectedDeviceBarView {
    static func loadFromNib() -> ConnectedDeviceBarView {
        let views = NSBundle.mainBundle().loadNibNamed("ConnectedDeviceView", owner: nil, options: nil)
        return views.first as! ConnectedDeviceBarView
    }
}