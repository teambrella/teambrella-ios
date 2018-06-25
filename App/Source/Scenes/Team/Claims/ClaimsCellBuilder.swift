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
    static func populate(cell: UICollectionViewCell, with claim: ClaimEntity) {
        guard let cell = cell as? ClaimsCell else { return }

        let session = service.session
        let currencySymbol = session?.currentTeam?.currencySymbol ?? ""

        cell.ownerAvatarView.show(claim.avatar)
        cell.titleLabel.text = claim.model
        cell.ownerNameLabel.text = claim.name.entire.uppercased()
        
        if let cell = cell as? ClaimsOpenCell {
            cell.avatarView.show(claim.smallPhoto)
            cell.button.setTitle("Team.ClaimsCell.viewToVote".localized, for: .normal)
            cell.claimedAmountLabel.text = currencySymbol + claim.claimAmount.formatted
            cell.claimedTitleLabel.text = "Team.ClaimsCell.claimed".localized.uppercased()
        } else if let cell = cell as? ClaimsVotedCell {
            //cell.avatarView.showAvatar(string: claim.smallPhoto)
            cell.avatarView.show(claim.smallPhoto)
            cell.claimedAmountLabel.text = currencySymbol + claim.claimAmount.formatted
            cell.claimedTitleLabel.text = "Team.ClaimsCell.claimed".localized.uppercased()
            if let vote = claim.myVote {
            cell.votedLabel.text = "Team.Claims.VotedCell.voted".localized
                + String.truncatedNumber(vote.percentage)
                + "%"
            } else {
                cell.votedLabel.text = ""
            }
            if let name = claim.proxyName {
                cell.voterLabel.isHidden = false
                cell.voterLabel.text = "By " + name.short
            } else {
                cell.voterLabel.isHidden = true
            }
        } else if let cell = cell as? ClaimsPaidCell {
            cell.avatarView.show(claim.smallPhoto)
            if claim.state == .declined {
                cell.statusLabel.text = "Team.ClaimsCell.declined".localized.uppercased()
                cell.statusLabel.textColor = .red
                cell.scaleBar.isLineHidden = true
            } else {
                cell.statusLabel.text = "Team.ClaimsCell.reimbursed".localized.uppercased()
                cell.statusLabel.textColor = .blueyGray
                cell.scaleBar.isLineHidden = false
            }
            cell.amountLabel.text = currencySymbol + claim.claimAmount.formatted
            cell.scaleBar.value = CGFloat(claim.reimbursement.value)
        }
    }
}
