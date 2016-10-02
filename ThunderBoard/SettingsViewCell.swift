//
//  SettingsViewCell.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class SettingsViewCell : UITableViewCell {
    
    var drawBottomSeparator: Bool = false
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if drawBottomSeparator {
            let path = UIBezierPath()
            let lineWidth: CGFloat = 1.0
            path.moveToPoint(CGPointMake(15, rect.size.height - lineWidth))
            path.addLineToPoint(CGPointMake(rect.width, rect.size.height - lineWidth))
            path.lineWidth = lineWidth
            
            StyleColor.lightGray.setStroke()
            path.stroke()
        }
    }
    
}
