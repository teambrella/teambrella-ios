//
//  ClaimsCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Kingfisher
import UIKit

struct ClaimsCellBuilder {
     static func populate(cell: UICollectionViewCell, with claim: ClaimLike) {
        if let cell = cell as? ClaimsOpenCell {
            cell.avatarView.kf.setImage(with: URL(string: service.server.avatarURLstring(for:claim.smallPhoto)),
                                        placeholder: #imageLiteral(resourceName: "imagePlaceholder"))
            cell.claimedAmountLabel.text = String(format: "%.2f", claim.claimAmount)
            cell.claimedTitleLabel.text = "Team.ClaimsCell.claimed".localized.uppercased()
            cell.titleLabel.text = claim.model
            cell.ownerAvatarView.kf.setImage(with: URL(string: service.server.avatarURLstring(for:claim.avatar)))
            cell.ownerNameLabel.text = claim.name
            cell.button.setTitle("Team.ClaimsCell.viewToVote".localized, for: .normal)
        } else if let cell = cell as? ClaimsVotedCell {
            cell.avatarView.kf.setImage(with: URL(string: service.server.avatarURLstring(for:claim.smallPhoto)),
                                        placeholder: #imageLiteral(resourceName: "imagePlaceholder"))
            cell.ownerAvatarView.kf.setImage(with: URL(string: service.server.avatarURLstring(for:claim.avatar)),
                                             placeholder: #imageLiteral(resourceName: "imagePlaceholder"))
            cell.ownerNameLabel.text = claim.name
            cell.claimedAmountLabel.text = String(format: "%.2f", claim.claimAmount)
            cell.claimedTitleLabel.text = "Team.ClaimsCell.claimed".localized.uppercased()
            cell.titleLabel.text = claim.model
         
        } else if let cell = cell as? ClaimsPaidCell {
            cell.avatarView.kf.setImage(with: URL(string: service.server.avatarURLstring(for:claim.smallPhoto)),
                                        placeholder: #imageLiteral(resourceName: "imagePlaceholder"))
            cell.titleLabel.text = claim.model
            cell.ownerAvatarView.kf.setImage(with: URL(string: service.server.avatarURLstring(for:claim.avatar)),
                                             placeholder: #imageLiteral(resourceName: "imagePlaceholder"))
            cell.ownerNameLabel.text = claim.name
           cell.amountLabel.text =  String(format: "%.2f", claim.claimAmount)
            cell.statusLabel.text = "Team.ClaimsCell.reimbursed".localized.uppercased()
            cell.scaleBar.value = CGFloat(claim.reimbursement)
        }
    }
}
