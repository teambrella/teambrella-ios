//
//  FeedDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import Foundation

class FeedDataSource {
    let teamID: Int
    private var items: [FeedEntity] = []
    var count: Int { return items.count }
    
    var offset = 0
    var since: UInt64 = 0
    let limit = 100
    
    var isSilentUpdate = false
    
    var onLoad: (() -> Void)?
    
    init(teamID: Int) {
        self.teamID = teamID
    }
    
    func loadData() {
        let offset = isSilentUpdate ? 0 : count
        let context = FeedRequestContext(teamID: teamID, since: since, offset: offset, limit: limit)
        service.storage.requestTeamFeed(context: context).observe { [weak self] result in
            switch result {
            case let .value(feed):
                guard let `self` = self else { return }
                
                if self.isSilentUpdate {
                    self.items.removeAll()
                    self.isSilentUpdate = false
                }
                self.items.append(contentsOf: feed)
                self.onLoad?()
            case let .error(error):
                log("\(error)", type: .error)
            }
        }
    }
    
    func updateSilently() {
        isSilentUpdate = true
        loadData()
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
