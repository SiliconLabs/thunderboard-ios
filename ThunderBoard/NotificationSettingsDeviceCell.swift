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
    
    fileprivate let actionStyle = StyleText.headerActive
    
    var drawSeparator: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if drawSeparator {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 15, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.lineWidth = 1
            
            StyleColor.lightGray.setStroke()
            path.stroke()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = StyleColor.white
        self.contentView.backgroundColor = UIColor.clear
        
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = StyleColor.white
        deviceName?.style = StyleText.main1
        deviceStatus?.style = StyleText.subtitle1
        setActionTitle("")
        
        actionButton?.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
    }
    
    func setActionTitle(_ title: String) {
        actionButton?.setAttributedTitle(actionStyle.attributedString(title), for: UIControlState())
    }
    
    @objc fileprivate func actionButtonTapped(_ sender: AnyObject?) {
        actionHandler?()
    }
}
