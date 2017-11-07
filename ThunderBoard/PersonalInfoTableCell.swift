//
//  PersonalInfoTableCell.swift
//  Thunderboard
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
        textField?.tintColor = StyleColor.terbiumGreen
        textField?.delegate = self
        
        log.debug("\(textField?.subviews)")
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
    
    fileprivate func setupClearButton() {

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        let image = UIImage(named: "icn_settings_textfield_clear")!
        button.setImage(image, for: UIControlState())
        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        
        textField?.rightViewMode = .whileEditing
        textField?.rightView = button
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        log.debug("\(textField.subviews)")
    }
    
    @objc func clearButtonTapped() {
        textField?.text = ""
    }
}
