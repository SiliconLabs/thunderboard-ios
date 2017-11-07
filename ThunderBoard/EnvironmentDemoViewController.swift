//
//  EnvironmentDemoViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EnvironmentDemoViewController: DemoViewController, EnvironmentDemoInteractionOutput, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    var interaction: EnvironmentDemoInteraction?
    fileprivate var dataSource = EnvironmentDemoCollectionViewDataSource()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Environment"
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.register(EnvironmentDemoCollectionViewCell.self, forCellWithReuseIdentifier: EnvironmentDemoCollectionViewCell.cellIdentifier)
        
        dataSource.activeViewModels.debounce(0.5, scheduler: MainScheduler.instance).bind(to: collectionView.rx.items(cellIdentifier: EnvironmentDemoCollectionViewCell.cellIdentifier, cellType: EnvironmentDemoCollectionViewCell.self)){(_, element, cell) in
            cell.configureCell(with: element)
        }.disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.withLatestFrom(dataSource.activeViewModels).debug().subscribe(onNext: { [weak self] viewModels in
            guard let strongSelf = self,
                let indexPath = strongSelf.collectionView.indexPathsForSelectedItems?.first,
                indexPath.item < viewModels.count else {
                    return
            }
            let viewModel = viewModels[indexPath.item]
            if viewModel.capability == .hallEffectState {
                if strongSelf.dataSource.currentHallEffectState == .tamper {
                    strongSelf.interaction?.resetTamperState()
                } else {
                    print("Current state is not tamper")
                }
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tb_setNavigationBarStyleForDemo(.environment)
        self.interaction?.updateView()
    }
    
    // MARK: - EnvironmentDemoInteractionOutput

    func updatedEnvironmentData(_ data: EnvironmentData, capabilities: Set<DeviceCapability>) {
        dataSource.updateData(data, capabilities: capabilities)
    }
}
