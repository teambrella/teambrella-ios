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

class UserIndexDataSource {
    var items: [UserIndexCellModel] = []
    var count: Int { return items.count }
    let teamID: Int
    let limit: Int = 10
    let search: String = ""
    var meModel: UserIndexCellModel?
    var isLoading: Bool = false
    var hasMore: Bool = true
    var canLoad: Bool { return hasMore && !isLoading }
    var sortType: SortVC.SortType = .ratingHiLo {
        didSet {
            items.removeAll()
            hasMore = true
        }
    }
    
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(teamID: Int) {
        self.teamID = teamID
    }
    
    subscript(indexPath: IndexPath) -> UserIndexCellModel {
        return items[indexPath.row]
    }
    
    subscript(index: Int) -> UserIndexCellModel {
        return items[index]
    }
    
    func loadData() {
        guard canLoad else { return }
        
        isLoading = true
        service.server.updateTimestamp { [weak self] timestamp, error in
            let key = Key(base58String: ServerService.privateKey,
                          timestamp: timestamp)
            guard let id = self?.teamID, var offset = self?.count, let limit = self?.limit,
                let search = self?.search, let sort = self?.sortType else { return }
            
            if self?.meModel != nil { offset += 1 }
            let body = RequestBody(key: key, payload:["TeamId": id,
                                                      "Offset": offset,
                                                      "Limit": limit,
                                                      "Search": search,
                                                      "SortBy": sort.rawValue])
            let request = TeambrellaRequest(type: .proxyRatingList, body: body, success: { [weak self] response in
                if case .proxyRatingList(var proxies, _) = response {
                    self?.hasMore = (proxies.count == limit)
                    let myID = service.session?.currentUserID
                    for (idx, proxy) in proxies.enumerated().reversed() where proxy.userID == myID {
                        self?.meModel = proxy
                        proxies.remove(at: idx)
                        break
                    }
                    self?.items += proxies
                    self?.isLoading = false
                    self?.onUpdate?()
                }
                }, failure: { [weak self] error in
                    self?.isLoading = false
                    self?.onError?(error)
            })
            request.start()
        }
    }
}
