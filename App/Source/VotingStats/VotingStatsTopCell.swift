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

class VotingStatsTopCell: UICollectionViewCell {
    
    @IBOutlet var lowerTitleLabel: Label!
    @IBOutlet var lowerValueLabel: Label!
    @IBOutlet var lowerInfoLabel: Label!

    @IBOutlet var sameTitleLabel: Label!
    @IBOutlet var sameValueLabel: Label!
    @IBOutlet var sameInfoLabel: Label!

    @IBOutlet var higherTitleLabel: Label!
    @IBOutlet var higherValueLabel: Label!
    @IBOutlet var higherInfoLabel: Label!


    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(with vc: VotingStatsVC) {
        sameTitleLabel.text = "Team.VotingStats.sameAsTeam" .localized.uppercased()
        lowerInfoLabel.text = "Team.VotingStats.ofTimes" .localized.uppercased()
        sameInfoLabel.text = "Team.VotingStats.ofTimes" .localized.uppercased()
        higherInfoLabel.text = "Team.VotingStats.ofTimes" .localized.uppercased()
        lowerValueLabel.textColor = .perrywinkle
        sameValueLabel.textColor = .blueyGray
        higherValueLabel.textColor = .darkSkyBlue
        
        lowerValueLabel.text = String(format: "%.0f%%", (1-vc.voteAsTeamOrBetter)*100)
        sameValueLabel.text = String(format: "%.0f%%", vc.voteAsTeam*100)
        higherValueLabel.text = String(format: "%.0f%%", (vc.voteAsTeamOrBetter-vc.voteAsTeam)*100)

        if (vc.isClaimsStats) {
            lowerTitleLabel.text = "Team.VotingStats.lessThanTeam" .localized.uppercased()
            higherTitleLabel.text = "Team.VotingStats.moreThanTeam" .localized.uppercased()
        } else {
            lowerTitleLabel.text = "Team.VotingStats.higherThanTeam" .localized.uppercased()
            higherTitleLabel.text = "Team.VotingStats.lowerThanTeam" .localized.uppercased()
        }
    }
 }
