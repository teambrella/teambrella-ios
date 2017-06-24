//
//  FeedDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct FeedDataSource {
    private var items: [FeedCellModel] = []
    var count: Int { return items.count }
    
    init() {
        items = fakeModels()
    }
    
    subscript(indexPath: IndexPath) -> FeedCellModel {
        return items[indexPath.row]
    }
    
}

extension FeedDataSource {
    func fakeModels() -> [FeedCellModel] {
        return [FeedCellModel](repeating: FeedCellModel.fake, count: 10)
    }
}
