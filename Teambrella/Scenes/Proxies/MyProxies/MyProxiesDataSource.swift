//
//  MyProxiesDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct MyProxiesDataSource {
    var items: [ProxyCellModel] = []
    var count: Int { return items.count }
    
    init() {
        for idx in 1...10 {
            items.append(ProxyCellModel.fake(name: "Test User \(idx)"))
        }
    }
    
    mutating func move(from indexPath: IndexPath, to: IndexPath) {
        let item = items.remove(at: indexPath.row)
        items.insert(item, at: to.row)
    }
    
    subscript(indexPath: IndexPath) -> ProxyCellModel {
        return items[indexPath.row]
    }
    
}
