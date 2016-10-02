//
//  EnvironmentDemoCollectionViewCell.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class EnvironmentDemoCollectionViewCell : UICollectionViewCell {

    let titleLabel = StyledLabel(style: .header2)
    let valueLabel = StyledLabel(style: .demoStatus)
    let iconImageView = UIImageView(image: UIImage(named: "icn_demo_ambient_light_inactive")!)
    let iconBackgroundView = UIImageView(image: nil)
    private let iconContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func updateValue(label: String, imageName: String, backgroundColor: UIColor?, power: Bool? = nil) {
        let maskImageName = "icn_demo_tint_circle"
        iconImageView.image = UIImage(named: imageName)
        
        if let backgroundColor = backgroundColor {
            iconBackgroundView.image = UIImage.tb_imageNamed(maskImageName, color: backgroundColor)
        }
        else {
            iconBackgroundView.image = nil
        }

        valueLabel.text = label
    }
    
    private func commonInit() {
        backgroundColor = UIColor.clearColor()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconContainer)
        contentView.addSubview(iconBackgroundView)
        contentView.addSubview(iconImageView)
        contentView.addSubview(valueLabel)

        contentView.subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        
        NSLayoutConstraint.activateConstraints([
            titleLabel.leadingAnchor.constraintEqualToAnchor(iconContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraintEqualToAnchor(iconContainer.trailingAnchor),
            titleLabel.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 18),
            
            iconContainer.widthAnchor.constraintEqualToAnchor(iconContainer.heightAnchor),
            iconContainer.topAnchor.constraintEqualToAnchor(titleLabel.bottomAnchor, constant: 10),
            iconContainer.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor, constant: -10),
            iconContainer.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor),
            
            iconImageView.centerXAnchor.constraintEqualToAnchor(iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraintEqualToAnchor(iconContainer.centerYAnchor, constant: -10),
            
            iconBackgroundView.centerXAnchor.constraintEqualToAnchor(iconContainer.centerXAnchor),
            iconBackgroundView.centerYAnchor.constraintEqualToAnchor(iconContainer.centerYAnchor, constant: -10),
            
            valueLabel.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor),
            valueLabel.lastBaselineAnchor.constraintEqualToAnchor(iconContainer.bottomAnchor, constant: -10),
        ])

        titleLabel.text = "TEMPERATURE"
        valueLabel.text = "--"
        iconContainer.backgroundColor = StyleColor.white
        iconContainer.tb_applyCommonRoundedCornerWithShadowStyle()
    }
}
