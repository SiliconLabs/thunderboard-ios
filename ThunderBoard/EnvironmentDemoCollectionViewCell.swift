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
    fileprivate let iconContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func updateValue(_ label: String, imageName: String, backgroundColor: UIColor?, power: Bool? = nil) {
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
    
    fileprivate func commonInit() {
        backgroundColor = UIColor.clear
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconContainer)
        contentView.addSubview(iconBackgroundView)
        contentView.addSubview(iconImageView)
        contentView.addSubview(valueLabel)

        contentView.subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            
            iconContainer.widthAnchor.constraint(equalTo: iconContainer.heightAnchor),
            iconContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            iconContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            iconContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor, constant: -10),
            
            iconBackgroundView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconBackgroundView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor, constant: -10),
            
            valueLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            valueLabel.lastBaselineAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: -10),
        ])

        titleLabel.text = "TEMPERATURE"
        valueLabel.text = "--"
        iconContainer.backgroundColor = StyleColor.white
        iconContainer.tb_applyCommonRoundedCornerWithShadowStyle()
    }
}
