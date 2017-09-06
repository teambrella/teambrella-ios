//
//  MembersDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.05.17.

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
import SwiftyJSON

enum TeammateSectionType {
    case new, teammate
}

class MembersDatasource {
    private var strategy: MembersFetchStrategy
    
    var isSilentUpdate = false
    
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    let orderByRisk: Bool
    
    var offset = 0
    var isLoading = false
    var sections: Int { return strategy.sections }
    var sortType: SortVC.SortType { return strategy.sortType }
    func itemsInSection(section: Int) -> Int { return strategy.itemsInSection(section: section) }
    func type(indexPath: IndexPath) -> TeammateSectionType { return strategy.type(indexPath: indexPath) }
    func headerTitle(indexPath: IndexPath) -> String { return strategy.headerTitle(indexPath: indexPath) }
    func headerSubtitle(indexPath: IndexPath) -> String { return strategy.headerSubtitle(indexPath: indexPath) }
    func sort(type: SortVC.SortType) {
        strategy.sort(type: type)
        onUpdate?()
    }
    
    init(orderByRisk: Bool) {
        self.orderByRisk = orderByRisk
        self.strategy = orderByRisk ? MembersRiskStrategy() : MembersListStrategy()
    }
    
    func setRanges(ranges: [RiskScaleEntity.Range]) {
        strategy.ranges = ranges
    }
    
    func updateSilently() {
        isSilentUpdate = true
        loadData()
    }
   
    func loadData() {
        let offset = isSilentUpdate ? 0 : sections
        guard !isLoading else { return }
        
        isLoading = true
        service.server.updateTimestamp { timestamp, error in
            let key = Key(base58String: ServerService.privateKey,
                          timestamp: timestamp)
            
            let body = RequestBody(key: key, payload:["TeamId": ServerService.teamID,
                                                      "Offset": offset,
                                                      "Limit": 1000,
                                                      "AvatarSize": 128,
                                                      "OrderByRisk": self.orderByRisk])
            let request = TeambrellaRequest(type: .teammatesList, body: body, success: { [weak self] response in
                guard let `self` = self else { return }
                
                if case .teammatesList(let teammates) = response {
                    if self.isSilentUpdate {
                        //self.items.removeAll()
                        self.isSilentUpdate = false
                    }
                    self.strategy.arrange(teammates: teammates)
                    self.offset += teammates.count
                    self.onUpdate?()
                    self.isLoading = false
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
        
    }
        
    subscript(indexPath: IndexPath) -> TeammateLike {
        return strategy[indexPath]
    }
    
}
