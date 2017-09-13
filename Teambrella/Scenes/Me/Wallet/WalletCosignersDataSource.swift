//
//  WalletCosignersDataSource.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 13.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

class WalletCosignersDataSource {
    var items: [WalletCosignersCellModel] = []
    var count: Int { return items.count }
    let teamID: Int = 0
    let limit: Int = 100
    var isSilentUpdate = false
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    var offset = 0
    var isLoading = false
    
    init() {
    }
    
    func updateSilently() {
        isSilentUpdate = true
        loadData()
    }
    
    func loadData() {
        let offset = isSilentUpdate ? 0 : count
        guard !isLoading else { return }
        
        isLoading = true
        service.server.updateTimestamp { timestamp, error in
            let key = Key(base58String: ServerService.privateKey,
                          timestamp: timestamp)
            
            let body = RequestBody(key: key, payload:["TeamId": ServerService.teamID,
                                                      "Offset": offset,
                                                      "Limit": 1000,
                                                      "AvatarSize": 128])
            let request = TeambrellaRequest(type: .teammatesList, body: body, success: { [weak self] response in
                guard let `self` = self else { return }
                
                if case .teammatesList(let teammates) = response {
                    if self.isSilentUpdate {
                        self.items.removeAll()
                        self.isSilentUpdate = false
                    }
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

    subscript(indexPath: IndexPath) -> WalletCosignersCellModel/*TeammateLike*/ {
        let model = items[indexPath.row]
        return model
    }
}
