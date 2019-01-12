//
//  UserIndexDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.

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

class UserIndexDataSource: StandardDataSource {
    var items: [UserIndexCellModel] = []
    let teamID: Int
    let limit: Int = 100
    let search: String = ""
    var meModel: UserIndexCellModel?
    var meIdx: Int = 0
    var isLoading: Bool = false
    var hasMore: Bool = true
    var canLoad: Bool { return hasMore && !isLoading }
    var sortType: SortVC.SortType = .ratingHiLo {
        didSet {
            items.removeAll()
            hasMore = true
        }
    }
    
    var isInRating: Bool = false {
        didSet {
            guard let me = meModel else { return }
            
            if isInRating {
                items.insert(me, at: meIdx)
            } else {
                items.remove(at: meIdx)
            }
        }
    }
    
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(teamID: Int) {
        self.teamID = teamID
    }
    
    subscript(index: Int) -> UserIndexCellModel {
        return items[index]
    }
    
    func loadData() {
        guard canLoad else { return }
        
        isLoading = true
        let offset = meModel != nil ? count + 1 : count
        service.dao.requestProxyRating(teamID: teamID,
                                       offset: offset,
                                       limit: limit,
                                       searchString: search,
                                       sortBy: sortType)
            .observe { [weak self] result in
                guard let `self` = self else { return }
                
                switch result {
                case var .value(proxyRatingEntity):
                    self.hasMore = (proxyRatingEntity.members.count == self.limit)
                    let myID = service.session?.currentUserID
                    for (idx, proxy) in proxyRatingEntity.members.enumerated().reversed() where proxy.userID == myID {
                        self.meModel = proxy
                        self.meIdx = idx
                        proxyRatingEntity.members.remove(at: idx)
                        break
                    }
                    self.items += proxyRatingEntity.members
                    self.onUpdate?()
                case let .error(error):
                    log(error)
                    self.onError?(error)
                }
                self.isLoading = false
        }
    }
}
