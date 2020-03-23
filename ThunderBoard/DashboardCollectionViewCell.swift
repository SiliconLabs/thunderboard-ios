//
//  DashboardCollectionViewCell.swift
//  Thunderboard
//
//  Created by Jan Wisniewski on 27/01/2020.
//  Copyright © 2020 Silicon Labs. All rights reserved.
//

import UIKit
import RxSwift

class DashboardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var demoSpinner: UIActivityIndicatorView!
    
    var disposeBag = DisposeBag()
    
    let cornerRadius: CGFloat = 16.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutCanvas()
        layoutSpinner()
    }
    
    private func layoutCanvas() {
        canvasView.layer.cornerRadius = cornerRadius
        canvasView.layer.masksToBounds = true
    }
    
    private func layoutSpinner() {
        demoSpinner.isHidden = true
    }
    
    func configureCell(with viewModel: EnvironmentDemoViewModel) {
        viewModel.name.asObservable().distinctUntilChanged().bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.value.asObservable().distinctUntilChanged().bind(to: detailsLabel.rx.text).disposed(by: disposeBag)
        viewModel.imageName.asObservable().distinctUntilChanged().map{ UIImage(named: $0) }.bind(to: icon.rx.image).disposed(by: disposeBag)
        viewModel.imageBackgroundColor.asObservable().distinctUntilChanged(==)
            .subscribe(onNext: { backgroundColor in
                let maskImageName = "icn_demo_tint_circle"
                if let backgroundColor = backgroundColor {
                    self.icon.image = UIImage.tb_imageNamed(maskImageName, color: backgroundColor)
                }
                else {
                    self.icon.image = nil
                }
            }).disposed(by: disposeBag)
    }
}
