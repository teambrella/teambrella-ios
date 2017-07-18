//
//  ClaimsCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
