//
//  EnvironmentCollectionViewCell.swift
//  Thunderboard
//
//  Created by Jan Wisniewski on 07/02/2020.
//  Copyright © 2020 Silicon Labs. All rights reserved.
//

import UIKit
import RxSwift

class EnvironmentCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "EnvironmentCollectionViewCell"
    
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    let cornerRadius: CGFloat = 16.0
    var disposeBag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutCanvas()
    }
    
    private func layoutCanvas() {
        canvasView.layer.cornerRadius = cornerRadius
        canvasView.layer.masksToBounds = true
    }
    
    func configureCell(with viewModel: EnvironmentDemoViewModel) {
        viewModel.name.asObservable().distinctUntilChanged().bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.value.asObservable().distinctUntilChanged().bind(to: detailsLabel.rx.text).disposed(by: disposeBag)
        viewModel.imageName.asObservable().distinctUntilChanged().map{ UIImage(named: $0) }.bind(to: icon.rx.image).disposed(by: disposeBag)
        /*viewModel.imageBackgroundColor.asObservable().distinctUntilChanged(==)
            .subscribe(onNext: { backgroundColor in
                if let backgroundColor = backgroundColor {
                    self.icon.image = UIImage.tb_imageNamed(maskImageName, color: backgroundColor)
                }
                else {
                    self.icon.image = nil
                }
            }).disposed(by: disposeBag)*/
    }
}
