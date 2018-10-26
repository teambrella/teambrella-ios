//
//  PrivateMessagesDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.08.17.
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
//

import UIKit

class PrivateMessagesDataSource: NSObject, StandardDataSource {
    var isLoading: Bool = false
    
    let limit = 100
    var offset = 0
    var hasNext: Bool = true
    var previousFilter: String?
    var filter: String?
    
    var items: [PrivateChatUser] = []
  
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    func loadData() {
        if filter != previousFilter { items.removeAll() }
        previousFilter = filter
        isLoading = true
        service.dao.requestPrivateList(offset: offset, limit: limit, filter: filter).observe { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            switch result {
            case let .value(users):
                self.items.append(contentsOf: users)
                self.offset += users.count
                self.hasNext = users.count == self.limit
                self.onUpdate?()
            case .error:
                break
            }
        }
    }
    
    func reload() {
        offset = 0
        hasNext = true
        items = []
        loadData()
    }
    
}
