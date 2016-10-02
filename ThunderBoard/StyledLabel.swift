//
//  StyledLabel.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class StyledLabel: UILabel {

    var style: StyleText?
    
    convenience init(style: StyleText) {
        self.init()
        self.style = style
    }
    
    @objc override var text: String? {
        get {
            return super.text
        }
        set {
            if self.style == nil {
                super.text = newValue
            } else {
                super.tb_setText(newValue!, style: self.style!)
            }
        }
    }
}
