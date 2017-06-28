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
    var cellIDs: [String] = []
    
    var sections: Int { return 1 }
    
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    func rows(for section: Int) -> Int {
        return cellIDs.count
    }
    
    func cellID(for indexPath: IndexPath) -> String {
        return cellIDs[indexPath.row]
    }
    
    private func setupClaim(claim: EnhancedClaimEntity) {
        self.claim = claim
        cellIDs.append(ImageGalleryCell.cellID)
        if claim.hasVotingPart {
            cellIDs.append(ClaimVoteCell.cellID)
        }
        cellIDs.append(ClaimDetailsCell.cellID)
        cellIDs.append(ClaimOptionsCell.cellID)
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
                    self?.setupClaim(claim: claim)
                    self?.onUpdate?()
                    print("Loaded enhanced claim \(claim)")
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
    }
    
    func updateVoteOnServer(vote: Float?) {
        let claimID = claim?.id ?? "0"
        let lastUpdated = claim?.lastUpdated ?? 0
        service.server.updateTimestamp { timestamp, error in
            let key = Key(base58String: ServerService.Constant.fakePrivateKey,
                          timestamp: timestamp)
            
            let body = RequestBody(key: key, payload:["ClaimId": claimID,
                                                      "MyVote": vote ?? NSNull(),
                                                      "Since": lastUpdated,
                                                      "ProxyAvatarSize": Constant.proxyAvatarSize])
            let request = TeambrellaRequest(type: .claimVote, body: body, success: { [weak self] response in
                if case .claimVote(let json) = response {
                    self?.claim?.update(with: json)
                    self?.onUpdate?()
                    print("Updated claim with \(json)")
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
    }
    
    func getUpdates() {
        let claimID = claim?.id ?? "0"
        let lastUpdated = claim?.lastUpdated ?? 0
        service.server.updateTimestamp { timestamp, error in
            let key = Key(base58String: ServerService.Constant.fakePrivateKey,
                          timestamp: timestamp)
            
            let body = RequestBody(key: key, payload:["ClaimId": claimID,
                                                      "Since": lastUpdated,
                                                      "ProxyAvatarSize": Constant.proxyAvatarSize])
            let request = TeambrellaRequest(type: .claimUpdates, body: body, success: { [weak self] response in
                if case .claimUpdates(let json) = response {
                    self?.claim?.update(with: json)
                    self?.onUpdate?()
                    print("updated claim \(json)")
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
    }
    
}
