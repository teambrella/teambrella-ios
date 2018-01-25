//
//  ClaimDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.

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

class ClaimDataSource {
    struct Constant {
        static let avatarSize = 64
        static let proxyAvatarSize = 32
    }
    
    var claim: ClaimEntityLarge?
    var cellIDs: [String] = []
    var userID: String { return claim?.userID ?? "" }
    
    var sections: Int { return 1 }
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    var voteCellIndexPath: IndexPath? {
        for (idx, id) in cellIDs.enumerated() where id == ClaimVoteCell.cellID {
            return IndexPath(row: idx, section: 0)
        }
        return nil
    }
    
    func rows(for section: Int) -> Int {
        return cellIDs.count
    }
    
    func cellID(for indexPath: IndexPath) -> String {
        return cellIDs[indexPath.row]
    }
    
    private func setupClaim(claim: ClaimEntityLarge) {
        self.claim = claim
        cellIDs.append(ImageGalleryCell.cellID)
        if claim.hasVotingPart {
            cellIDs.append(ClaimVoteCell.cellID)
        }
        cellIDs.append(ClaimDetailsCell.cellID)
        cellIDs.append(ClaimOptionsCell.cellID)
    }
    
    func loadData(claimID: Int) {
        service.server.updateTimestamp { timestamp, error in
            let key =  Key(base58String: KeyStorage.shared.privateKey, timestamp: timestamp)
            
            let body = RequestBody(key: key, payload: ["id": claimID,
                                                      "AvatarSize": Constant.avatarSize,
                                                      "ProxyAvatarSize": Constant.proxyAvatarSize])
            let request = TeambrellaRequest(type: .claim, body: body, success: { [weak self] response in
                if case .claim(let claim) = response {
                    self?.setupClaim(claim: claim)
                    self?.onUpdate?()
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
    }
    
    func updateVoteOnServer(vote: Float?) {
        let claimID = claim?.id ?? 0
        let lastUpdated = claim?.lastUpdated ?? 0
        service.server.updateTimestamp { timestamp, error in
            let key =  Key(base58String: KeyStorage.shared.privateKey, timestamp: timestamp)
            
            let body = RequestBody(key: key, payload: ["ClaimId": claimID,
                                                      "MyVote": vote ?? NSNull(),
                                                      "Since": lastUpdated,
                                                      "ProxyAvatarSize": Constant.proxyAvatarSize])
            let request = TeambrellaRequest(type: .claimVote, body: body, success: { [weak self] response in
                if case .claimVote(let json) = response {
                    self?.claim?.update(with: json)
                    self?.onUpdate?()
                    log("Updated claim with \(json)", type: .serviceInfo)
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
    }
    
    func getUpdates() {
        let claimID = claim?.id ?? 0
        let lastUpdated = claim?.lastUpdated ?? 0
        service.server.updateTimestamp { timestamp, error in
            let key =  Key(base58String: KeyStorage.shared.privateKey, timestamp: timestamp)
            
            let body = RequestBody(key: key, payload: ["ClaimId": claimID,
                                                      "Since": lastUpdated,
                                                      "ProxyAvatarSize": Constant.proxyAvatarSize])
            let request = TeambrellaRequest(type: .claimUpdates, body: body, success: { [weak self] response in
                if case .claimUpdates(let json) = response {
                    self?.claim?.update(with: json)
                    self?.onUpdate?()
                    log("updated claim \(json)", type: .serviceInfo)
                }
                }, failure: { [weak self] error in
                    self?.onError?(error)
            })
            request.start()
        }
    }
    
}
