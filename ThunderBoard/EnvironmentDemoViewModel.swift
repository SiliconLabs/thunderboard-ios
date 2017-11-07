//
//  EnvironmentDemoViewModel.swift
//  Thunderboard
//
//  Created by Jamal Sedayao on 9/26/17.
//  Copyright © 2017 Silicon Labs. All rights reserved.
//

import Foundation
import RxSwift

class EnvironmentDemoViewModel {
    let capability: DeviceCapability
    let name: Variable<String> = Variable("")
    let value: Variable<String> = Variable("")
    let imageName: Variable<String> = Variable("")
    let imageBackgroundColor: Variable<UIColor?> = Variable(nil)
    
    init(capability: DeviceCapability) {
        self.capability = capability
    }
    
    func updateData(cellData: EnvironmentCellData) {
        self.name.value = cellData.name
        self.value.value = cellData.value
        self.imageName.value = cellData.imageName
        self.imageBackgroundColor.value = cellData.imageBackgroundColor
    }
}
