//
//  PersonalInfoTableCell.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class PersonalInfoTableCell : UITableViewCell, UITextFieldDelegate {

    @IBOutlet var textField: UITextField?
    var drawSeparator: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupClearButton()

        // cursor color
        textField?.tintColor = StyleColor.blue
        textField?.delegate = self
        
        log.debug("\(textField?.subviews)")
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
    
    private func setupClearButton() {

        let button = UIButton(frame: CGRectMake(0, 0, 18, 18))
        let image = UIImage(named: "icn_settings_textfield_clear")!
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: Selector("clearButtonTapped"), forControlEvents: .TouchUpInside)
        
        textField?.rightViewMode = .WhileEditing
        textField?.rightView = button
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        log.debug("\(textField.subviews)")
    }
    
    @objc func clearButtonTapped() {
        textField?.text = ""
    }
}