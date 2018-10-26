//
//  ProxyForDataSource.swift
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

class ProxyForDataSource: StandardDataSource {
    var items: [ProxyForCellModel] = []

    let teamID: Int
    let limit: Int = 100
    var commission: Double = 0.0
    
    var isSilentUpdate = false
    
    var isLoading: Bool = false
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(teamID: Int) {
        self.teamID = teamID
    }
    
    func updateSilently() {
        isSilentUpdate = true
        loadData()
    }
    
    func loadData() {
        guard !isLoading else { return }
        
        isLoading = true
        let offset = isSilentUpdate ? 0 : count
        service.dao.requestProxyFor(teamID: teamID, offset: offset, limit: limit).observe { [weak self] result in
            guard let self = self else { return }

            self.isLoading = false
            switch result {
            case let .value(proxyForEntity):
                if self.isSilentUpdate {
                    self.items.removeAll()
                    self.isSilentUpdate = false
                }
                self.items += proxyForEntity.members
                self.commission = proxyForEntity.totalCommission
                self.onUpdate?()
            case let .error(error):
                self.onError?(error)
            }
        }
    }
}
