//
//  MotionDemoCalibrateButton.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class MotionDemoCalibrateButton: UIButton {

    override var highlighted: Bool {
        get {
            return super.highlighted
        }
        
        set {
            let color = newValue ? StyleColor.bromineOrange : UIColor.tb_hex(0xff9435)
            self.layer.borderColor = color.CGColor
            super.highlighted = newValue
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 2
        let color = UIColor.tb_hex(0xff9435)
        self.layer.borderColor = color.CGColor
        let title = StyleText.buttonLabel.tweakColor(color: color).attributedString("CALIBRATE")
        self.setAttributedTitle(title, forState: UIControlState.Normal)
        let highlightedTitle = StyleText.buttonLabel.tweakColor(color: StyleColor.bromineOrange).attributedString("CALIBRATE")
        self.setAttributedTitle(highlightedTitle, forState: UIControlState.Highlighted)
    }
    
}
