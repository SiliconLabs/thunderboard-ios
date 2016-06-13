//
//  SettingsTableViewHeader.swift
//  ThunderBoard
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
    
    private var titleLabel: StyledLabel = StyledLabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        titleLabel.style = StyleText.header
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        self.contentView.addSubview(titleLabel)
        self.contentView.addConstraint(NSLayoutConstraint(
            item: titleLabel,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: self.contentView,
            attribute: .Leading,
            multiplier: 1,
            constant: 15)
        )
        
        self.contentView.addConstraint(NSLayoutConstraint(
            item: titleLabel,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: self.contentView,
            attribute: .Trailing,
            multiplier: 1,
            constant: -15)
        )
        
        self.contentView.addConstraint(NSLayoutConstraint(
            item: titleLabel,
            attribute: .Baseline,
            relatedBy: .Equal,
            toItem: self.contentView,
            attribute: .Bottom,
            multiplier: 1,
            constant: -10)
        )
    }
}