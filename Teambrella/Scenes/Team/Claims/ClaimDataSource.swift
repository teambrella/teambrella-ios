//
//  ClaimDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

class ClaimDataSource {
    struct Constant {
        static let avatarSize = 64
        static let proxyAvatarSize = 32
    }
    
    var claim: EnhancedClaimEntity?
    
    var sections: Int { return 1 }
    
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    func rows(for section: Int) -> Int {
        return claim == nil ? 0 : 4
    }
    
    func cellID(for indexPath: IndexPath) -> String {
        switch indexPath.row {
        case 0:  return ImageGalleryCell.cellID
        case 1: return ClaimVoteCell.cellID
        case 2: return ClaimDetailsCell.cellID
        case 3: return ClaimOptionsCell.cellID
        default: return ""
        }
       
    }
    
    func loadData(claimID: String) {
        service.server.updateTimestamp { timestamp, error in
            let key = Key(base58String: ServerService.Constant.fakePrivateKey,
                          timestamp: timestamp)
            
            let body = RequestBody(key: key, payload:["id": Int(claimID) ?? 0,
                                                      "AvatarSize": Constant.avatarSize,
                                                      "ProxyAvatarSize": Constant.proxyAvatarSize])
            let request = TeambrellaRequest(type: .claim, body: body, success: { [weak self] response in
                if case .claim(let claim) = response {
                    self?.claim = claim
                    self?.onUpdate?()
                    print("Loaded enhanced claim \(claim)")
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
    }
    
}
