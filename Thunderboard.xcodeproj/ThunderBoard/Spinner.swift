//
//  Spinner.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

@IBDesignable
class Spinner: UIView {

    let colorPathLayer = CAShapeLayer()
    let trackPathLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }

    override func prepareForInterfaceBuilder() {
        commonSetup()
        self.hidesWhenStopped = false
        colorPathLayer.strokeStart = 0.0
        colorPathLayer.strokeEnd = 0.4
    }
    
    var lineWidth: CGFloat = 2.0 {
        didSet {
            colorPathLayer.lineWidth = lineWidth
            trackPathLayer.lineWidth = lineWidth
        }
    }
    
    var trackColor: UIColor = UIColor.lightGrayColor() {
        didSet {
            trackPathLayer.strokeColor = trackColor.CGColor
        }
    }
    
    var lineColor: UIColor = UIColor.blueColor() {
        didSet {
            colorPathLayer.strokeColor = lineColor.CGColor
        }
    }
    
    var hidesWhenStopped: Bool = true {
        didSet {
            if hidesWhenStopped {
                self.hidden = !self.isAnimating
            }
        }
    }

    private var isAnimating = false
    func startAnimating(duration: NSTimeInterval) {

        if isAnimating == false {
            isAnimating = true
            
            let strokeEndAnim = CABasicAnimation(keyPath: "strokeEnd")
            strokeEndAnim.toValue = 1.0
            strokeEndAnim.duration = duration
            strokeEndAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            strokeEndAnim.repeatCount = HUGE
            strokeEndAnim.removedOnCompletion = false
            
            colorPathLayer.addAnimation(strokeEndAnim, forKey: nil)
            self.hidden = false
        }
    }
    
    func stopAnimating() {
        isAnimating = false
        colorPathLayer.removeAllAnimations()
        self.hidden = self.hidesWhenStopped
    }
    
    
    //MARK:- Internal
    
    override func layoutSubviews() {
        super.layoutSubviews()

        trackPathLayer.frame = bounds
        trackPathLayer.path = circlePath().CGPath
        
        colorPathLayer.frame = bounds
        colorPathLayer.path = circlePath().CGPath
    }
    
    private func commonSetup() {
        
        setupTrackPath()
        layer.addSublayer(trackPathLayer)
        
        setupColorPath()
        layer.addSublayer(colorPathLayer)
        
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
        self.hidden = hidesWhenStopped
    }
    
    private func setupTrackPath() {
        trackPathLayer.frame = bounds
        trackPathLayer.lineWidth = lineWidth
        trackPathLayer.fillColor = UIColor.clearColor().CGColor
        trackPathLayer.strokeColor = trackColor.CGColor
        trackPathLayer.strokeStart = 0
        trackPathLayer.strokeEnd = 1
    }
    
    private func setupColorPath() {
        colorPathLayer.frame = bounds
        colorPathLayer.lineWidth = lineWidth
        colorPathLayer.fillColor = UIColor.clearColor().CGColor
        colorPathLayer.strokeColor = lineColor.CGColor
        colorPathLayer.strokeStart = 0
        colorPathLayer.strokeEnd = 0
        colorPathLayer.lineCap = "butt"
    }
    
    private func circlePath() -> UIBezierPath {
        return UIBezierPath(arcCenter: CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds)),
            radius: (bounds.size.width - lineWidth) / 2,
            startAngle: CGFloat(M_PI_2),
            endAngle: CGFloat(5*M_PI_2),
            clockwise: true)
    }
}
