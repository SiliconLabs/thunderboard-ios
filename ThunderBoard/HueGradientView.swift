//
//  HueGradientView.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class HueGradientView: UIView {

    override class var layerClass : AnyClass {
        return CAGradientLayer.self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    fileprivate func commonInit() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.colors = {
            return (0 ..< 360).map({ (degree) -> CGColor in
                return UIColor(hue: (CGFloat(degree)/CGFloat(360)), saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor
            })
        }()
    }
    
    fileprivate var gradientLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }
    
}
