//
//  ClaimsDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

class ClaimsDataSource {
    struct Constant {
        static let loadLimit = 10
        static let avatarSize = 128
    }
    
    private var claims: [ClaimLike] = []
    var count: Int { return claims.count }
    
    var offset = 0
    var isLoading = false
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    func loadData() {
        guard !isLoading else { return }
        
        isLoading = true
        service.server.updateTimestamp { timestamp, error in
            let key = Key(base58String: ServerService.Constant.fakePrivateKey,
                          timestamp: timestamp)
            
            let body = RequestBody(key: key, payload:["TeamId": ServerService.Constant.teamID,
                                                      "Offset": self.offset,
                                                      "Limit": Constant.loadLimit,
                                                      "AvatarSize": Constant.avatarSize])
            let request = TeambrellaRequest(type: .claimsList, body: body, success: { [weak self] response in
                if case .claimsList(let claims) = response {
                    guard let me = self else { return }
                    
                    me.offset += claims.count
                    me.onUpdate?()
                    me.isLoading = false
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
        
    }
    
    subscript(indexPath: IndexPath) -> ClaimLike {
        return claims[indexPath.row]
    }
}
