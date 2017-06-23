//
//  WalletCellModels.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol WalletCellModel {
    
}

struct WalletHeaderCellModel: WalletCellModel {
    let amount: Double
    let reserved: Double
    let available: Double
    
    static var fake: WalletCellModel { return WalletHeaderCellModel(amount: 0, reserved: 0, available: 0) }
}

struct WalletFundingCellModel: WalletCellModel {
    let maxCoverageFunding: Double
    let uninterruptedCoverageFundingh: Double
    
    static var fake: WalletCellModel {
        return WalletFundingCellModel(maxCoverageFunding: 0, uninterruptedCoverageFundingh: 0)
    }
}

struct WalletButtonsCellModel: WalletCellModel {
    let avatars: [String]
    
    static var fake: WalletCellModel { return WalletButtonsCellModel(avatars: []) }
}
