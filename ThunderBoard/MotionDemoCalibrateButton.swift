//
//  MotionDemoCalibrateButton.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class MotionDemoCalibrateButton: UIButton {

    fileprivate let normalColor = StyleColor.terbiumGreen
    fileprivate let highlightColor = StyleColor.mediumGreen
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        
        set {
            let color = newValue ? highlightColor : normalColor
            self.layer.borderColor = color.cgColor
            super.isHighlighted = newValue
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 2
        
        self.layer.borderColor = normalColor.cgColor
        
        let title = StyleText.buttonLabel.tweakColor(color: normalColor).attributedString("CALIBRATE")
        self.setAttributedTitle(title, for: UIControlState())
        
        let highlightedTitle = StyleText.buttonLabel.tweakColor(color: highlightColor).attributedString("CALIBRATE")
        self.setAttributedTitle(highlightedTitle, for: .highlighted)
    }
    
}
