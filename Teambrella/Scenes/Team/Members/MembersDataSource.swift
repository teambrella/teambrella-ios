//
//  MembersDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

enum TeammateSectionType {
    case new, teammate
}

class MembersDatasource {
    
    var strategy: MembersFetchStrategy = MembersListStrategy()
    
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    let orderByRisk: Bool
    var ranges: [RiskScaleEntity.Range] = []
    
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
    }
   
    func loadData() {
        //fakeLoadData()
        guard !isLoading else { return }
        
        isLoading = true
        service.server.updateTimestamp { timestamp, error in
            let key = Key(base58String: ServerService.privateKey,
                          timestamp: timestamp)
            
            let body = RequestBody(key: key, payload:["TeamId": ServerService.teamID,
                                                      "Offset": self.offset,
                                                      "Limit": 1000,
                                                      "AvatarSize": 128,
                                                      "OrderByRisk": self.orderByRisk])
            let request = TeambrellaRequest(type: .teammatesList, body: body, success: { [weak self] response in
                if case .teammatesList(let teammates) = response {
                    guard let me = self else { return }
                    
                    me.strategy.arrange(teammates: teammates)
                    me.offset += teammates.count
                    me.onUpdate?()
                    me.isLoading = false
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
        
    }
    
    /*
    func sortByRisk(_ teammates: [TeammateLike]) {
        var arrayOfRanges: [[TeammateLike]] = []
        for range in ranges {
            var arrayOfTeammatesInRange: [TeammateLike] = []
            for teammate in teammates {
                if teammate.risk >= range.left && teammate.risk <= range.right {
                    arrayOfTeammatesInRange.append(teammate)
                }
            }
            arrayOfRanges.append(arrayOfTeammatesInRange)
        }
    }
    */
    
    subscript(indexPath: IndexPath) -> TeammateLike {
        return strategy[indexPath]
    }
    
}
