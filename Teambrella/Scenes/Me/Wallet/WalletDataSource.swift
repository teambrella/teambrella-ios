//
//  WalletDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct WalletDataSource {
    var items: [WalletCellModel] = []
    var count: Int { return items.count }
    
    init() {
      items = fakeModels()
    }
    
    subscript(indexPath: IndexPath) -> WalletCellModel {
        return items[indexPath.row]
    }
}

extension WalletDataSource {
    func fakeModels() -> [WalletCellModel] {
        return [WalletHeaderCellModel.fake, WalletFundingCellModel.fake, WalletButtonsCellModel.fake]
    }
}
