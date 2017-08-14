//
//  ProxyForDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct ProxyForDataSource {
    var items: [ProxyForCellModel] = []
    var count: Int { return items.count }
    
    init() {
//        for _ in 1...10 {
//            items.append(ProxyForCellModel.fake())
//        }
    }
    
    subscript(indexPath: IndexPath) -> ProxyForCellModel {
        return items[indexPath.row]
    }
    
}
