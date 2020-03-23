//
//  DeviceTableViewCell.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {
    
    let canvasCornerRadius: CGFloat = 16.0
    
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rssiImage: UIImageView!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var connectingSpinner: Spinner!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        canvasView.layer.cornerRadius = canvasCornerRadius
        canvasView.layer.masksToBounds = true
    }
}
