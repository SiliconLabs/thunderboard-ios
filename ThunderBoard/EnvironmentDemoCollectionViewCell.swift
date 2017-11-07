//
//  EnvironmentDemoCollectionViewCell.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit
import RxSwift

class EnvironmentDemoCollectionViewCell: UICollectionViewCell {

    static let cellIdentifier = "\(self).cellID"
    
    // MARK: - Properties

    let titleLabel = StyledLabel(style: .header2)
    let valueLabel = StyledLabel(style: .demoStatus)
    let iconImageView = UIImageView(image: UIImage(named: "icn_demo_ambient_light_inactive")!)
    let iconBackgroundView = UIImageView(image: nil)
    fileprivate let iconContainer = UIView()
    var disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        valueLabel.text = nil
        iconImageView.image = nil
        iconBackgroundView.image = nil
        disposeBag = DisposeBag()
    }

    // MARK: - Actions

    func configureCell(with viewModel: EnvironmentDemoViewModel) {
        viewModel.name.asObservable().distinctUntilChanged().bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.value.asObservable().distinctUntilChanged().bind(to: valueLabel.rx.text).disposed(by: disposeBag)
        viewModel.imageName.asObservable().distinctUntilChanged().map{ UIImage(named: $0) }.bind(to: iconImageView.rx.image).disposed(by: disposeBag)
        viewModel.imageBackgroundColor.asObservable().distinctUntilChanged(==)
            .subscribe(onNext: { backgroundColor in
                let maskImageName = "icn_demo_tint_circle"
                if let backgroundColor = backgroundColor {
                    self.iconBackgroundView.image = UIImage.tb_imageNamed(maskImageName, color: backgroundColor)
                }
                else {
                    self.iconBackgroundView.image = nil
                }
            }).disposed(by: disposeBag)
    }

    // MARK: Setup

    fileprivate func commonInit() {
        backgroundColor = UIColor.clear

        contentView.addSubview(titleLabel)
        contentView.addSubview(iconContainer)
        contentView.addSubview(iconBackgroundView)
        contentView.addSubview(iconImageView)
        contentView.addSubview(valueLabel)

        contentView.subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })


        titleLabel.minimumScaleFactor = 0.5
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.setContentCompressionResistancePriority(1000, for: .vertical)
        titleLabel.setContentHuggingPriority(1000, for: .vertical)

        valueLabel.numberOfLines = 0
        valueLabel.textAlignment = .center
        valueLabel.setContentHuggingPriority(1000, for: .vertical)
        valueLabel.setContentCompressionResistancePriority(1000, for: .vertical)

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
            valueLabel.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor),
        ])

        titleLabel.text = "TEMPERATURE"
        valueLabel.text = "--"
        iconContainer.backgroundColor = StyleColor.white
        iconContainer.tb_applyCommonRoundedCornerWithShadowStyle()
    }
}
