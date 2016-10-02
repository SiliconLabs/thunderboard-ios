//
//  ButtonSpinner.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

public let π = M_PI

class ButtonAnimationTrackLayer: CALayer {
    
    private let trackLayer = CAShapeLayer()
    
    override init() {
        super.init()
        commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    var lineWidth: CGFloat = 1.0 {
        didSet {
            trackLayer.lineWidth = lineWidth
        }
    }
    
    var trackColor: UIColor = UIColor.redColor() {
        didSet {
            setupTrack()
        }
    }
    
    var beginning: CGFloat = CGFloat(π) {
        didSet {
            setupTrack()
        }
    }
    
    var ending: CGFloat = CGFloat(π) {
        didSet {
            setupTrack()
        }
    }
    
    var delayDuration: Double = 0.5
    var fillDuration: Double = 1
    var reverseDuration: Double = 1
    var rotationDuration: Double = 2
    
    enum AnimationDirection {
        case Clockwise
        case Counterclockwise
    }
    var direction: AnimationDirection = .Clockwise
    
    private var animating = false
    private var filling = false
    private var starting = false
    private var stopping = false
    
    var currentAngle : CGFloat?
    var currentPath : UIBezierPath?
    
    func startAnimating() {
        if (animating && stopping) {
            stopping = false
            return
        }
        
        setupTrack()
        starting = true
        stopping = false
        animating = true
        start()
    }
    
    func stopAnimating() {
        stopping = true
    }
    
    func start() {
        setupPath(false)
        
        trackLayer.removeAnimationForKey("stroke")
        
        let strokeEndAnim = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnim.fromValue = 1.0
        strokeEndAnim.toValue = 0.02
        strokeEndAnim.duration = 0.7
        strokeEndAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        strokeEndAnim.removedOnCompletion = false
        strokeEndAnim.delegate = self
        
        trackLayer.strokeEnd = 0.02
        trackLayer.addAnimation(strokeEndAnim, forKey: "stroke")
    }
    
    func stop() {
        trackLayer.removeAnimationForKey("stroke")

        let strokeEndAnim = CABasicAnimation(keyPath: "strokeColor")
        strokeEndAnim.fromValue = trackColor.CGColor
        strokeEndAnim.toValue = StyleColor.gray.CGColor
        strokeEndAnim.duration = 0.5
        strokeEndAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        strokeEndAnim.removedOnCompletion = false
        strokeEndAnim.delegate = self
        
        trackLayer.strokeColor = StyleColor.gray.CGColor
        trackLayer.addAnimation(strokeEndAnim, forKey: "stroke")
    }
    
    func rotate() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        
        animation.duration = rotationDuration
        animation.fromValue = 0.0
        animation.toValue = 2.0 * π
        animation.repeatCount = HUGE
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.removedOnCompletion = false
        
        self.addAnimation(animation, forKey: "rotation")
    }
    
    func fill() {
        filling = true
        
        setupPath(true)
        
        trackLayer.removeAnimationForKey("stroke")
        
        let strokeEndAnim = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnim.fromValue = 0.02
        strokeEndAnim.toValue = 1.0
        strokeEndAnim.duration = fillDuration
        strokeEndAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        strokeEndAnim.removedOnCompletion = false
        strokeEndAnim.delegate = self
        
        trackLayer.strokeEnd = 1.0
        trackLayer.addAnimation(strokeEndAnim, forKey: "stroke")
    }
    
    func reverse() {
        filling = false
        
        setupPath(false)
        
        trackLayer.removeAnimationForKey("stroke")
        
        let strokeEndAnim = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnim.fromValue = 1.0
        strokeEndAnim.toValue = 0.02
        strokeEndAnim.duration = reverseDuration
        strokeEndAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        strokeEndAnim.removedOnCompletion = false
        strokeEndAnim.delegate = self
        
        trackLayer.strokeEnd = 0.02
        trackLayer.addAnimation(strokeEndAnim, forKey: "stroke")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if starting {
            animating = true
            starting = false
            setupTrack()
            fill()
            rotate()
            return
        }
        
        if stopping {
            animating = false
            stopping = false
            fill()
            stop()
            return
        }
        
        if !animating {
            self.removeAllAnimations()
            return
        }
        
        if filling {
            reverse()
        } else {
            delay(delayDuration) {
                self.fill()
            }
        }
    }
    
    private func commonSetup() {
        self.addSublayer(trackLayer)
        setupTrack()
    }
    
    private func setupTrack() {
        trackLayer.frame = bounds
        trackLayer.fillColor = UIColor.clearColor().CGColor
        trackLayer.lineCap = "round"
        trackLayer.strokeColor = trackColor.CGColor
        trackLayer.strokeStart = 0.0
        trackLayer.strokeEnd = 1.0
        
        if (animating == false) {
            trackLayer.strokeColor = StyleColor.gray.CGColor
        }
    }
    
    private func setupPath(clockwise : Bool) {
        
        if (clockwise == false) {
            if let path = currentPath {
                trackLayer.path = path.bezierPathByReversingPath().CGPath
                return
            }
        }
        
        var startAngle = beginning
        
        if let start = currentAngle {
            startAngle = start
        }
        
        if (startAngle > CGFloat(2 * π)) {
            startAngle = startAngle - CGFloat(2 * π)
        }
        
        let endAngle = startAngle + ending
        
        currentAngle = endAngle
        
        let bezierPath : UIBezierPath = {
            return UIBezierPath(arcCenter: CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds)),
                radius: (self.bounds.size.width - lineWidth) / 2,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: clockwise)
            }()
        
        currentPath = bezierPath
        
        trackLayer.path = bezierPath.CGPath
    }
    
    override var frame: CGRect {
        get { return super.frame }
        set (value) { super.frame = value
            setupPath(true)
        }
    }
}

class ButtonSpinner: UIView {
    
    private let tracks = [
        ButtonAnimationTrackLayer(),
        ButtonAnimationTrackLayer(),
        ButtonAnimationTrackLayer(),
        ButtonAnimationTrackLayer()
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private var isAnimating = false
    
    func startAnimating() {
        if isAnimating == false {
            isAnimating = true
            tracks.forEach({ $0.startAnimating() })
        }
    }
    
    func stopAnimating() {
        if isAnimating {
            isAnimating = false
            tracks.forEach({ $0.stopAnimating() })
        }
    }
    
    //MARK:- Internal
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for (index, track) in tracks.enumerate() {
            let inset = 16 + (10 * index)
            track.frame = CGRectInset(self.bounds, CGFloat(inset), CGFloat(inset))
            track.anchorPoint = CGPointMake(0.5, 0.5)
        }
    }
    
    private func commonSetup() {
        
        let trackColors = [
            StyleColor.brightGreen,
            StyleColor.terbiumGreen,
            StyleColor.mediumGreen,
            StyleColor.darkGreen
        ]
        
        let start = -π / 2.0
        let end = 2 * π
        let widths = [ 3.0, 2.5, 2.0, 1.5 ]
        let endings = [ end, end, end, end ]
        
        let delayTimings = [ 0.5, 0.2, 0.1, 0.0 ]
        let fillTimings = [ 1.0, 1.2, 1.4, 1.3 ]
        let reverseTimings = [ 0.5, 0.6, 0.5, 0.7 ]
        let rotationTimings = [ 1.0, 1.0 + 1.0 / 3.0, 2.0, 4.0 ]
        
        for (index, track) in tracks.enumerate() {
            track.delayDuration = delayTimings[index]
            track.fillDuration = fillTimings[index]
            track.reverseDuration = reverseTimings[index]
            track.rotationDuration = rotationTimings[index]
            track.beginning = CGFloat(start)
            track.ending = CGFloat(endings[index])
            track.lineWidth = CGFloat(widths[index])
            track.trackColor = trackColors[index]
            
            self.layer.addSublayer(track)
        }
        
        self.backgroundColor = UIColor.clearColor()
    }
}