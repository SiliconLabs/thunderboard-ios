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
        self.init(frame: CGRect.zero)
    }
    
    fileprivate func commonInit() {
        addSubview(connectedToLabel)
        addSubview(deviceNameLabel)
        addSubview(batteryStatusLabel)
        addSubview(batteryStatusImage)
        addSubview(firmwareVersionLabel)
        
        subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        
        let leadingMargin: CGFloat = 15
        NSLayoutConstraint.activate([
            
            // CONNECTED TO
            connectedToLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leadingMargin),
            connectedToLabel.bottomAnchor.constraint(equalTo: deviceNameLabel.topAnchor, constant: 2),
            connectedToLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            // DEVICE NAME
            deviceNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leadingMargin),
            deviceNameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            // FIRMWARE VERSION
            firmwareVersionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leadingMargin),
            firmwareVersionLabel.topAnchor.constraint(equalTo: deviceNameLabel.lastBaselineAnchor, constant: 2),
            firmwareVersionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            // BATTERY %
            batteryStatusLabel.leadingAnchor.constraint(equalTo: deviceNameLabel.trailingAnchor, constant: 15),
            batteryStatusLabel.trailingAnchor.constraint(equalTo: batteryStatusImage.leadingAnchor, constant: -8),
            batteryStatusLabel.firstBaselineAnchor.constraint(equalTo: deviceNameLabel.firstBaselineAnchor),
            
            // BATTERY IMAGE
            batteryStatusImage.widthAnchor.constraint(equalToConstant: 39),
            batteryStatusImage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            batteryStatusImage.centerYAnchor.constraint(equalTo: deviceNameLabel.centerYAnchor, constant: 1),
        ])
        
        deviceNameLabel.lineBreakMode = .byTruncatingMiddle
        batteryStatusLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: UILayoutConstraintAxis.horizontal)
    }
}
