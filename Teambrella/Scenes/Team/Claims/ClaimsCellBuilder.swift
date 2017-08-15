//
//  ClaimsCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.06.17.

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

import Kingfisher
import UIKit

protocol ClaimsCell {
    var avatarView: UIImageView! { get }
    var titleLabel: Label! { get }
    var ownerAvatarView: RoundImageView! { get }
    var ownerNameLabel: Label! { get }
}

struct ClaimsCellBuilder {
    static func populate(cell: UICollectionViewCell, with claim: ClaimLike) {
        guard let cell = cell as? ClaimsCell else { return }
        
        cell.ownerAvatarView.showAvatar(string: claim.avatar)
        cell.ownerNameLabel.text = claim.name
        cell.titleLabel.text = claim.model
        
        if let cell = cell as? ClaimsOpenCell {
            cell.avatarView.showAvatar(string: claim.smallPhoto)
            cell.button.setTitle("Team.ClaimsCell.viewToVote".localized, for: .normal)
            cell.claimedAmountLabel.text = String(format: "%.2f", claim.claimAmount)
            cell.claimedTitleLabel.text = "Team.ClaimsCell.claimed".localized.uppercased()
        } else if let cell = cell as? ClaimsVotedCell {
            cell.avatarView.showAvatar(string: claim.smallPhoto)
            cell.claimedAmountLabel.text = String(format: "%.2f", claim.claimAmount)
            cell.claimedTitleLabel.text = "Team.ClaimsCell.claimed".localized.uppercased()
        } else if let cell = cell as? ClaimsPaidCell {
            cell.avatarView.showImage(string: claim.smallPhoto)
            cell.statusLabel.text = "Team.ClaimsCell.reimbursed".localized.uppercased()
            cell.scaleBar.value = CGFloat(claim.reimbursement)
        }
    }
}
