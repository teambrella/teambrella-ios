//
//  MyProxiesDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

class MyProxiesDataSource {
    var items: [ProxyCellModel] = []
    var count: Int { return items.count }
    let teamID: Int
    let limit: Int = 100
    
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    init(teamID: Int) {
        self.teamID = teamID
    }
    
    func move(from indexPath: IndexPath, to: IndexPath) {
        let item = items.remove(at: indexPath.row)
        items.insert(item, at: to.row)
    }
    
    subscript(indexPath: IndexPath) -> ProxyCellModel {
        return items[indexPath.row]
    }
    
    func loadData() {
        service.server.updateTimestamp { [weak self] timestamp, error in
            let key = Key(base58String: ServerService.privateKey,
                          timestamp: timestamp)
            guard let id = self?.teamID, let offset = self?.count, let limit = self?.limit else { return }
            
            let body = RequestBody(key: key, payload:["TeamId": id,
                                                      "Offset": offset,
                                                      "Limit": limit])
            let request = TeambrellaRequest(type: .myProxies, body: body, success: { [weak self] response in
                if case .myProxies(let proxies) = response {
                    self?.items += proxies
                    self?.onUpdate?()
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
    }
    
}
