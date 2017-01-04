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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if drawSeparator {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 15, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.lineWidth = 1
            
            StyleColor.lightGray.setStroke()
            path.stroke()
        }
    }
}
