//
//  Style.swift
//  ThunderBoard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

extension UIColor {
    class func tb_hex(hex: Int) -> UIColor {
        return UIColor(
            red:    CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green:  CGFloat((hex & 0x00FF00) >> 8)  / 255.0,
            blue:   CGFloat((hex & 0x0000FF) >> 0)  / 255.0,
            alpha:  1.0)
    }
}

extension UILabel {
    func tb_setText(text: String, style: StyleText) {
        self.attributedText = style.attributedString(text)
    }
}

extension String {
    static func tb_placeholderText() -> String {
        return "--"
    }
}

class StyleColor {
    
    class var darkGray: UIColor {
        get { return UIColor.tb_hex(0x333333) }
    }
    
    class var footerGray: UIColor {
        get { return UIColor.tb_hex(0x464646) }
    }
    
    class var siliconGray: UIColor {
        get { return UIColor.tb_hex(0x555555) }
    }
    
    class var mediumGray: UIColor {
        get { return UIColor.tb_hex(0x6c6c6c) }
    }
    
    class var gray: UIColor {
        get { return UIColor.tb_hex(0xc1c1c1) }
    }
    
    class var lightGray: UIColor {
        get { return UIColor.tb_hex(0xefefef) }
    }
    
    class var yellow: UIColor {
        get { return UIColor.tb_hex(0xffcc00) }
    }
    
    class var gold: UIColor {
        get { return UIColor.tb_hex(0xf0b323) }
    }
    
    class var bromineOrange: UIColor {
        get { return UIColor.tb_hex(0xff7100) }
    }
    
    class var red: UIColor {
        get { return UIColor.tb_hex(0xfb2f3c) }
    }
    
    class var redOrange: UIColor {
        get { return UIColor.tb_hex(0xe65100) }
    }
    
    class var pink: UIColor {
        get { return UIColor.tb_hex(0xff7469) }
    }
    
    class var yellowOrange: UIColor {
        get { return UIColor.tb_hex(0xffa200) }
    }
    
    class var blue: UIColor {
        get { return UIColor.tb_hex(0x00aeff) }
    }
    
    class var darkViolet: UIColor {
        get { return UIColor.tb_hex(0x857cff) }
    }
    
    class var violet: UIColor {
        get { return UIColor.tb_hex(0x9196ff) }
    }
    
    class var lightViolet: UIColor {
        get { return UIColor.tb_hex(0xc3caf8) }
    }
    
    class var whiteViolet: UIColor {
        get { return UIColor.tb_hex(0xe9e3ff) }
    }
    
    class var lightPeach: UIColor {
        get { return UIColor.tb_hex(0xfff4f1) }
    }
    
    class var peachGold: UIColor {
        get { return UIColor.tb_hex(0xffe7cf) }
    }
    
    class var lightBlue: UIColor {
        get { return UIColor.tb_hex(0x78d6ff) }
    }
    
    class var brightGreen: UIColor {
        get { return UIColor.tb_hex(0xcaf200) }
    }
    
    class var terbiumGreen: UIColor {
        get { return UIColor.tb_hex(0xa1b92e) }
    }
    
    class var mediumGreen: UIColor {
        get { return UIColor.tb_hex(0x87a10d) }
    }
    
    class var white: UIColor {
        get { return UIColor.whiteColor() }
    }
}

class StyleText {
    
    class var demoTitle: StyleText {
        get { return StyleText(fontName: .HelveticaNeueThin, size: 29, color: StyleColor.white, kerning: 25) }
    }
    
    class var demoStatus: StyleText {
        get { return StyleText(fontName: .HelveticaNeueLight, size: 19, color: StyleColor.white, kerning: 75) }
    }
    
    class var deviceName: StyleText {
        get { return StyleText(fontName: .HelveticaNeueLight, size: 19, color: StyleColor.white, kerning: nil) }
    }
    
    class var deviceName2: StyleText {
        get { return StyleText(fontName: .HelveticaNeueBold, size: 15, color: StyleColor.white, kerning: nil) }
    }
    
    class var deviceName3: StyleText {
        get { return StyleText(fontName: .HelveticaNeueLight, size: 19, color: StyleColor.gray, kerning: 25) }
    }
    
    class var header: StyleText {
        get { return StyleText(fontName: .HelveticaNeueLight, size: 12, color: StyleColor.gray, kerning: 25) }
    }
    
    class var header2: StyleText {
        get { return StyleText(fontName: .HelveticaNeueLight, size: 12, color: StyleColor.lightGray, kerning: 25) }
    }
    
    class var headerActive: StyleText {
        get { return StyleText(fontName: .HelveticaNeueBold, size: 12, color: StyleColor.gray, kerning: 25) }
    }
    
    class var main1: StyleText {
        get { return StyleText(fontName: .HelveticaNeueLight, size: 15, color: StyleColor.white, kerning: nil) }
    }
    
    class var navBarTitle: StyleText {
        get { return StyleText(fontName: .HelveticaNeueLight, size: 17, color: StyleColor.white, kerning: nil) }
    }
    
    class var numbers1: StyleText {
        get { return StyleText(fontName: .HelveticaNeueBold, size: 12, color: StyleColor.white, kerning: 25) }
    }
    
    class var streamingLabel: StyleText {
        get { return StyleText(fontName: .HelveticaNeueBold, size: 13, color: StyleColor.white, kerning: 25) }
    }
    
    class var subtitle1: StyleText {
        get { return StyleText(fontName: .HelveticaNeueLight, size: 12, color: StyleColor.gray, kerning: 25) }
    }
    
    class var subtitle2: StyleText {
        get { return StyleText(fontName: .HelveticaNeueBold, size: 10, color: StyleColor.gray, kerning: 25) }
    }
    
    class var demoValue: StyleText {
        get { return StyleText(fontName: .HelveticaNeueLight, size: 24, color: StyleColor.white, kerning: 75) }
    }
    
    class var buttonLabel: StyleText {
        get { return StyleText(fontName: .HelveticaNeueBold, size: 13, color: StyleColor.gray, kerning: nil) }
    }
    
    class var powered_by: StyleText {
        get { return StyleText(fontName: .HelveticaNeueRegular, size: 15, color: StyleColor.white, kerning: nil) }
    }
    class var launch_tagline: StyleText {
        get { return StyleText(fontName: .HelveticaNeueUltraLight, size: 31, color: StyleColor.lightGray, kerning: nil) }
    }
    class var launch_tagline_highlight: StyleText {
        get { return StyleText(fontName: .HelveticaNeueLight, size: 31, color: StyleColor.bromineOrange, kerning: nil) }
    }
    class var note: StyleText {
        get { return StyleText(fontName: .HelveticaNeueLight, size: 12, color: StyleColor.gray, kerning: 25) }
    }

    //MARK:-
    
    var font: UIFont
    var color: UIColor
    var kerning: CGFloat?
    
    init(fontName: FontName, size: CGFloat, color: UIColor, kerning: CGFloat?) {
        self.font = UIFont(name: fontName.rawValue, size: size)!
        self.color = color
        self.kerning = kerning
    }
    
    func attributedString(text: String) -> NSAttributedString {
        var attributes: [String:AnyObject] = [
            NSFontAttributeName : self.font,
            NSForegroundColorAttributeName : self.color
        ]
        
        if let kerning = self.kerning {
            let kerningAdjustment: CGFloat = 20.0
            attributes[NSKernAttributeName] = (kerning / kerningAdjustment)
        }
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        return attributedString
    }
    
    func tweakColor(color newColor: UIColor) -> StyleText {
        self.color = newColor
        return self
    }
    
    func tweakColorAlpha(alpha: CGFloat) -> StyleText {
        self.color = self.color.colorWithAlphaComponent(alpha)
        return self
    }
    
    enum FontName: String {
        case HelveticaNeueBold          = "HelveticaNeue-Bold"
        case HelveticaNeueLight         = "HelveticaNeue-Light"
        case HelveticaNeueRegular       = "HelveticaNeue-Regular"
        case HelveticaNeueThin          = "HelveticaNeue-Thin"
        case HelveticaNeueUltraLight    = "HelveticaNeue-UltraLight"
    }
}

class StyleAnimations {
    
    class var spinnerDuration: NSTimeInterval {
        get { return 1.5 }
    }
}
