//
//  FeedDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

class FeedDataSource {
    let teamID: Int
    private var items: [FeedEntity] = []
    var count: Int { return items.count }
    
    var offset = 0
    var since: UInt64 = 0
    let limit = 100
    
    var onLoad: (() -> Void)?
    
    init(teamID: Int) {
        self.teamID = teamID
    }
    
    func loadData() {
        service.storage.requestTeamFeed(teamID: teamID,
                                         since: since,
                                         offset: offset,
                                         limit: limit,
                                         success: { [weak self] feed in
                self?.items.append(contentsOf: feed)
        }) { error in
        
        }
    }
    
    subscript(indexPath: IndexPath) -> FeedEntity {
        return items[indexPath.row]
    }
    
}

extension FeedDataSource {
    func fakeModels() -> [FeedCellModel] {
        return [FeedCellModel](repeating: FeedCellModel.fake, count: 10)
    }
}
