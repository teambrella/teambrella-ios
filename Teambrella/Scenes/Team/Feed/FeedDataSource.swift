//
//  FeedDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct FeedDataSource {
    let teamID: Int
    private var items: [FeedCellModel] = []
    var count: Int { return items.count }
    
    var offset = 0
    var since: UInt64 = 0
    let limit = 100
    
    var onLoad: (() -> Void)?
    
    
    init(teamID: Int) {
        self.teamID = teamID
        items = fakeModels()
    }
    
    func loadData() {
        service.storage.requestTeamFeed(teamID: teamID,
                                         since: since,
                                         offset: offset,
                                         limit: limit,
                                         success: {
                                            
        }) { error in
        
        }
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
