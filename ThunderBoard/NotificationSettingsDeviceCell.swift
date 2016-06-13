//
//  NotificationSettingsDeviceCell.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class NotificationSettingsDeviceCell: UITableViewCell {

    @IBOutlet var deviceName: StyledLabel?
    @IBOutlet var deviceStatus: StyledLabel?
    @IBOutlet var actionButton: UIButton?
    
    typealias ActionHandler = ( () -> Void )
    var actionHandler: ActionHandler?
    
    private let actionStyle = StyleText(fontName: .HelveticaNeueBold, size: 12, color: StyleColor.gray, kerning: nil)
    
    var drawSeparator: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if drawSeparator {
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(15, 0))
            path.addLineToPoint(CGPointMake(rect.width, 0))
            path.lineWidth = 1
            
            StyleColor.white.colorWithAlphaComponent(0.18).setStroke()
            path.stroke()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = StyleColor.mediumGray
        self.contentView.backgroundColor = UIColor.clearColor()
        
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = StyleColor.darkGray
        deviceName?.style = StyleText(fontName: .HelveticaNeueLight, size: 16, color: StyleColor.white, kerning: nil)
        deviceStatus?.style = StyleText(fontName: .HelveticaNeueLight, size: 12, color: StyleColor.gray, kerning: nil)
        setActionTitle("")
        
        actionButton?.addTarget(self, action: Selector("actionButtonTapped:"), forControlEvents: .TouchUpInside)
    }
    
    func setActionTitle(title: String) {
        actionButton?.setAttributedTitle(actionStyle.attributedString(title), forState: UIControlState.Normal)
    }
    
    @objc private func actionButtonTapped(sender: AnyObject?) {
        actionHandler?()
    }
}
