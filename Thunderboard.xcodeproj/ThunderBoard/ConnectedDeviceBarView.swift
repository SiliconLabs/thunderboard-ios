//
//  ConnectedDeviceBarView.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class ConnectedDeviceBarView: UIView {
    let connectedToLabel = UILabel()
    let deviceNameLabel = UILabel()
    let batteryStatusLabel = UILabel()
    let batteryStatusImage = UIImageView(image: nil)
    let firmwareVersionLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    private func commonInit() {
        addSubview(connectedToLabel)
        addSubview(deviceNameLabel)
        addSubview(batteryStatusLabel)
        addSubview(batteryStatusImage)
        addSubview(firmwareVersionLabel)
        
        subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        
        let leadingMargin: CGFloat = 15
        NSLayoutConstraint.activateConstraints([
            
            // CONNECTED TO
            connectedToLabel.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor, constant: leadingMargin),
            connectedToLabel.bottomAnchor.constraintEqualToAnchor(deviceNameLabel.topAnchor, constant: 2),
            connectedToLabel.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor),
            
            // DEVICE NAME
            deviceNameLabel.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor, constant: leadingMargin),
            deviceNameLabel.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor),
            
            // FIRMWARE VERSION
            firmwareVersionLabel.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor, constant: leadingMargin),
            firmwareVersionLabel.topAnchor.constraintEqualToAnchor(deviceNameLabel.lastBaselineAnchor, constant: 2),
            firmwareVersionLabel.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor),
            
            // BATTERY %
            batteryStatusLabel.leadingAnchor.constraintEqualToAnchor(deviceNameLabel.trailingAnchor, constant: 15),
            batteryStatusLabel.trailingAnchor.constraintEqualToAnchor(batteryStatusImage.leadingAnchor, constant: -8),
            batteryStatusLabel.firstBaselineAnchor.constraintEqualToAnchor(deviceNameLabel.firstBaselineAnchor),
            
            // BATTERY IMAGE
            batteryStatusImage.widthAnchor.constraintEqualToConstant(39),
            batteryStatusImage.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor, constant: -15),
            batteryStatusImage.centerYAnchor.constraintEqualToAnchor(deviceNameLabel.centerYAnchor, constant: 1),
        ])
        
        deviceNameLabel.lineBreakMode = .ByTruncatingMiddle
        batteryStatusLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: UILayoutConstraintAxis.Horizontal)
    }
}