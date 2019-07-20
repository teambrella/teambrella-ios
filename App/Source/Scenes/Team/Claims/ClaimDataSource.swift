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
    var claim: ClaimEntityLarge?
    var cellIDs: [String] = []
    var userID: String { return claim?.basic.userID ?? "" }
    
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
        if claim.voting != nil || claim.voted != nil {
            cellIDs.append(ClaimVoteCell.cellID)
        }
        cellIDs.append(ClaimDetailsCell.cellID)
        if claim.voted != nil && claim.basic.votingRes.value > 0 {
            cellIDs.append(ClaimPayoutCell.cellID)
        }
        cellIDs.append(ClaimOptionsCell.cellID)
    }
    
    func loadData(claimID: Int) {
        service.dao.requestClaim(claimID: claimID).observe { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case let .value(claim):
                self.setupClaim(claim: claim)
                self.onUpdate?()
            case let .error(error):
                self.onError?(error)
            }
        }
    }
    
    func updateVoteOnServer(vote: Float?) {
        let claimID = claim?.id ?? 0
        let lastUpdated = claim?.lastUpdated ?? 0
        service.dao.updateClaimVote(claimID: claimID,
                                    vote: vote,
                                    lastUpdated: lastUpdated)
            .observe { [weak self] result in
                guard let `self` = self else { return }
                
                switch result {
                case let .value(voteUpdate):
                    self.claim?.update(with: voteUpdate)
                    self.onUpdate?()
                    log("Updated claim with \(voteUpdate)", type: .info)
                case let .error(error):
                    self.onError?(error)
                }
            }
    }

}
