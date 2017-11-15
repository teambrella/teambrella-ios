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

class ProxyForDataSource {
    var items: [ProxyForCellModel] = []
    var count: Int { return items.count }
    var isEmpty: Bool { return items.isEmpty }
    let teamID: Int
    let limit: Int = 100
    var commission: Double = 0.0
    
    var isSilentUpdate = false
    
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(teamID: Int) {
        self.teamID = teamID
    }
    
    subscript(indexPath: IndexPath) -> ProxyForCellModel {
        return items[indexPath.row]
    }
    
    func updateSilently() {
        isSilentUpdate = true
        loadData()
    }
    
    func loadData() {
        let offset = isSilentUpdate ? 0 : count
        service.server.updateTimestamp { [weak self] timestamp, error in
            let key =  Key(base58String: KeyStorage.shared.privateKey, timestamp: timestamp)
            guard let id = self?.teamID, let limit = self?.limit else { return }
            
            let body = RequestBody(key: key, payload: ["TeamId": id,
                                                      "Offset": offset,
                                                      "Limit": limit])
            let request = TeambrellaRequest(type: .proxyFor, body: body, success: { [weak self] response in
                guard let `self` = self else { return }
                
                if case .proxyFor(let proxies, let commission) = response {
                    if self.isSilentUpdate {
                        self.items.removeAll()
                        self.isSilentUpdate = false
                    }
                    self.items += proxies
                    self.commission = commission
                    self.onUpdate?()
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
    }
}
