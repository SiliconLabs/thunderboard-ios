//
//  MotionDemoCalibrateButton.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class MotionDemoCalibrateButton: UIButton {

    private let normalColor = StyleColor.terbiumGreen
    private let highlightColor = StyleColor.mediumGreen
    
    override var highlighted: Bool {
        get {
            return super.highlighted
        }
        
        set {
            let color = newValue ? highlightColor : normalColor
            self.layer.borderColor = color.CGColor
            super.highlighted = newValue
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 2
        
        self.layer.borderColor = normalColor.CGColor
        
        let title = StyleText.buttonLabel.tweakColor(color: normalColor).attributedString("CALIBRATE")
        self.setAttributedTitle(title, forState: .Normal)
        
        let highlightedTitle = StyleText.buttonLabel.tweakColor(color: highlightColor).attributedString("CALIBRATE")
        self.setAttributedTitle(highlightedTitle, forState: .Highlighted)
    }
    
}
