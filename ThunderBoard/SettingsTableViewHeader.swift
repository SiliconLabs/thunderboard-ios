//
//  SettingsTableViewHeader.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class SettingsTableViewHeader : UITableViewHeaderFooterView {

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    fileprivate var titleLabel: StyledLabel = StyledLabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    fileprivate func commonSetup() {
        titleLabel.style = StyleText.header
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(titleLabel)
        self.contentView.addConstraint(NSLayoutConstraint(
            item: titleLabel,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self.contentView,
            attribute: .leading,
            multiplier: 1,
            constant: 15)
        )
        
        self.contentView.addConstraint(NSLayoutConstraint(
            item: titleLabel,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self.contentView,
            attribute: .trailing,
            multiplier: 1,
            constant: -15)
        )
        
        self.contentView.addConstraint(NSLayoutConstraint(
            item: titleLabel,
            attribute: .lastBaseline,
            relatedBy: .equal,
            toItem: self.contentView,
            attribute: .bottom,
            multiplier: 1,
            constant: -10)
        )
    }
}
