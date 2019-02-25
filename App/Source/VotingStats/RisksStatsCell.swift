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

class RisksStatsCell: UICollectionViewCell {
    @IBOutlet var avatarView: RoundBadgedView!
    @IBOutlet var titleLabel: TitleLabel!
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var cellSeparator: UIView!
    @IBOutlet var statusLabel: Label!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func update(with model: RiskVotesListEntry) {
        let session = service.session
        
        let coverage = service.session?.currentTeam?.coverageType ?? .other
        let yearText = CoverageLocalizer(type: coverage).yearsString(year: model.year)
        avatarView.show(model.avatar)
        amountLabel.text = String(format: "%.1f", model.vote ?? 0)
        amountLabel.textColor = .blueyGray

        let diff = Int((model.vote ?? 0.0)*10.0 + 0.5) - Int((model.teamVote ?? 0.0)*10.0 + 0.5)
        if diff < 0 {
            amountLabel.textColor = .darkSkyBlue
        } else if diff > 0 {
            amountLabel.textColor = .perrywinkle
        }
//        let signColor: UIColor = teammate.totallyPaid > 0.0 ? .tealish : .lipstick
//        cell.signLabel.textColor = signColor
        statusLabel.text = model.proxyVoterID != nil ? "Team.TeammateCell.byProxy".localized.uppercased() : ""
        statusLabel.alpha = 0.5
        
        titleLabel.text = model.name.entire
        let detailsText: String = "\(model.model), \(yearText)".uppercased()
        detailsLabel.text = detailsText
        if let risk = model.teamVote {
            avatarView.badgeText = String(format: "%.1f", risk)
        } else {
            avatarView.badgeText = nil
        }
    }
 }
