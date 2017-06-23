//
//  WalletDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct WalletDataSource {
    var items: [UserIndexCellModel] = []
    var count: Int { return items.count }
    
    init() {
        for _ in 1...25 {
            items.append(UserIndexCellModel.fake())
        }
    }
    
    subscript(indexPath: IndexPath) -> UserIndexCellModel {
        return items[indexPath.row]
    }
}
