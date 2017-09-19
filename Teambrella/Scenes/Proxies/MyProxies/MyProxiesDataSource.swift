//
//  MyProxiesDataSource.swift
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

class MyProxiesDataSource {
    var items: [ProxyCellModel] = []
    var count: Int { return items.count }
    var isEmpty: Bool { return items.isEmpty }
    let teamID: Int
    let limit: Int = 100
    
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    var isSilentUpdate = false
    
    init(teamID: Int) {
        self.teamID = teamID
    }
    
    func move(from indexPath: IndexPath, to: IndexPath) {
        let item = items.remove(at: indexPath.row)
        items.insert(item, at: to.row)
        refreshDataFor(userID: items[to.row].userID, at: to.row)
    }
    
    subscript(indexPath: IndexPath) -> ProxyCellModel {
        let model = items[indexPath.row]
        return model
    }
    
    func updateSilently() {
        isSilentUpdate = true
        loadData()
    }
    
    func loadData() {
        let offset = isSilentUpdate ? 0 : count
        service.server.updateTimestamp { [weak self] timestamp, error in
            let key = Key(base58String: ServerService.privateKey,
                          timestamp: timestamp)
            guard let id = self?.teamID, let limit = self?.limit else { return }
            
            let body = RequestBody(key: key, payload:["TeamId": id,
                                                      "Offset": offset,
                                                      "Limit": limit])
            let request = TeambrellaRequest(type: .myProxies, body: body, success: { [weak self] response in
                guard let `self` = self else { return }
                
                if case .myProxies(let proxies) = response {
                    if self.isSilentUpdate {
                        self.items.removeAll()
                        self.isSilentUpdate = false
                    }
                    self.items += proxies
                    self.onUpdate?()
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
    }
    
    func refreshDataFor(userID: String, at position: Int) {
        service.server.updateTimestamp { [weak self] timestamp, error in
            let key = Key(base58String: ServerService.privateKey,
                          timestamp: timestamp)
            guard let id = self?.teamID else { return }
            
            let body = RequestBody(key: key, payload:["TeamId": id,
                                                      "UserId": userID,
                                                      "Position": position])
            let request = TeambrellaRequest(type: .proxyPosition, body: body, success: { response in
                if case .proxyPosition = response {
                    log("Position saved to server", type: .serviceInfo)
                }
            }, failure: { [weak self] error in
                self?.onError?(error)
            })
            request.start()
        }
    }
}
