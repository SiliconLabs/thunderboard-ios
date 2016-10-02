//
//  DeviceTableViewCell.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rssiImage: UIImageView!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var connectingSpinner: Spinner!

    var drawSeparator: Bool = false
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if drawSeparator {
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(15, 0))
            path.addLineToPoint(CGPointMake(rect.width, 0))
            path.lineWidth = 1
            
            StyleColor.lightGray.setStroke()
            path.stroke()
        }
    }
}
