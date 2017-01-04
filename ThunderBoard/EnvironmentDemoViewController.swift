//
//  EnvironmentDemoViewController.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class EnvironmentDemoViewController: DemoViewController, EnvironmentDemoInteractionOutput, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    var interaction: EnvironmentDemoInteraction?
    fileprivate var dataSource = EnvironmentDemoCollectionViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Environment"
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
        collectionView.backgroundColor = UIColor.clear
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        dataSource.registerCells(collectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.tb_setNavigationBarStyleForDemo(.environment)
        self.interaction?.updateView()
    }
    
    // MARK: - EnvironmentDemoInteractionOutput

    func updatedEnvironmentData(_ data: EnvironmentData, capabilities: Set<DeviceCapability>) {
        dataSource.updateData(data, capabilities: capabilities)
        collectionView.reloadData()
    }    
}
