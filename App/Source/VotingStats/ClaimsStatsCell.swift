//
/* Copyright(C) 2017 Teambrella, Inc.
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

import UIKit

class ClaimsStatsCell: UICollectionViewCell {
    
    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var ownerAvatarView: RoundImageView!
    @IBOutlet var ownerNameLabel: Label!
    @IBOutlet var amountLabel: Label!
    @IBOutlet var cellSeparator: UIView!
    @IBOutlet var statusLabel: Label!
    @IBOutlet var badge: Label!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(with claim: ClaimEntity) {
        ownerAvatarView.show(claim.avatar)
        titleLabel.text = claim.model
        ownerNameLabel.text = claim.name.entire.uppercased()
        avatarView.show(claim.smallPhoto)
        
        amountLabel.text = claim.myVote?.stringRounded ?? ""
        amountLabel.font = isSmallIPhone ? UIFont.teambrellaBold(size: 16) : UIFont.teambrellaBold(size: 20)
        amountLabel.textColor = .blueyGray

        let teamVote = Int(claim.reimbursement.value*100 + 0.5)
        let myVote = Int((claim.myVote?.value ?? 0)*100 + 0.5)
        let diff = myVote - teamVote
        if diff > 0 {
            amountLabel.textColor = .darkSkyBlue
        } else if diff < 0 {
            amountLabel.textColor = .perrywinkle
        }

        statusLabel.text = claim.proxyName != nil ? "Team.TeammateCell.byProxy".localized.uppercased() : ""
        statusLabel.alpha = 0.5

        badge.text = String(format: "%d%%", teamVote)
        badge.layer.masksToBounds = true
        badge.layer.borderWidth = 1.5
        let badgeFont: UIFont = UIFont.teambrella(size: 10)
        let badgeTextColor: UIColor = .white
        badge.layer.borderColor = badgeTextColor.cgColor
        badge.font = badgeFont
    }
 }
