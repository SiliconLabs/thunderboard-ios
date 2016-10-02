//
//  NotificationSettingsDeviceCell.swift
//  Thunderboard
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
    
    private let actionStyle = StyleText.headerActive
    
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
            
            StyleColor.lightGray.setStroke()
            path.stroke()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = StyleColor.white
        self.contentView.backgroundColor = UIColor.clearColor()
        
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = StyleColor.white
        deviceName?.style = StyleText.main1
        deviceStatus?.style = StyleText.subtitle1
        setActionTitle("")
        
        actionButton?.addTarget(self, action: #selector(actionButtonTapped(_:)), forControlEvents: .TouchUpInside)
    }
    
    func setActionTitle(title: String) {
        actionButton?.setAttributedTitle(actionStyle.attributedString(title), forState: UIControlState.Normal)
    }
    
    @objc private func actionButtonTapped(sender: AnyObject?) {
        actionHandler?()
    }
}
