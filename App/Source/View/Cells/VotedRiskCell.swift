//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import UIKit

class VotedRiskCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var titleLabel: BlockHeaderLabel!
    @IBOutlet var timeLabel: ThinStatusSubtitleLabel!
    @IBOutlet var pieChart: PieChartView!
    
    @IBOutlet var slashView: SlashView!
    @IBOutlet var teamVoteHeaderLabel: InfoLabel!
    @IBOutlet var teamVoteValueLabel: AmountLabel!
    @IBOutlet var teamVoteBadgeLabel: BadgeLabel!
    @IBOutlet var teamVoteNotAccept: AmountLabel!
    @IBOutlet var teammatesAvatarStack: RoundImagesStack!
    
    @IBOutlet var yourVoteHeaderLabel: InfoLabel!
    @IBOutlet var yourVoteValueLabel: AmountLabel!
    @IBOutlet var yourVoteBadgeLabel: BadgeLabel!
    @IBOutlet var yourVoteNotAccept: AmountLabel!
    
    @IBOutlet var proxyAvatarView: RoundImageView!
    @IBOutlet var proxyNameLabel: InfoLabel!
    
    @IBOutlet var teamVoteAVGLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var yourVoteAVGLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var yourVoteHeaderLabelLeadingConstraint: NSLayoutConstraint!
    
    private var dataSource: VotingScrollerDataSource = VotingScrollerDataSource()
    
    weak var delegate: VotingRiskCellDelegate?
    
    var isProxyHidden: Bool = true {
        didSet {
            proxyAvatarView.isHidden = isProxyHidden
            proxyNameLabel.isHidden = isProxyHidden
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLabels()
        setupButtons()
        
        self.clipsToBounds = true
        ViewDecorator.roundedEdges(for: self)
        ViewDecorator.shadow(for: self)
    }
    
    private func setupButtons() {
//        othersButton.titleLabel?.minimumScaleFactor = 0.7
//        othersButton.titleLabel?.adjustsFontSizeToFitWidth = true
//        othersButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
//        othersVotesButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
    }
    
    private func setupLabels() {
        titleLabel.text = "Team.VotingRiskVC.headerLabel".localized
        teamVoteHeaderLabel.text = "Team.VotingRiskVC.numberBar.left".localized
        teamVoteBadgeLabel.text = "Team.VotingRiskVC.avgLabel".localized(0)
        teamVoteBadgeLabel.backgroundColor = #colorLiteral(red: 0.5843137255, green: 0.6470588235, blue: 0.6941176471, alpha: 1)
        
        yourVoteHeaderLabel.text = "Team.VotingRiskVC.numberBar.right".localized
        yourVoteBadgeLabel.text = "Team.VotingRiskVC.avgLabel".localized(0)
        yourVoteBadgeLabel.backgroundColor = #colorLiteral(red: 0.5843137255, green: 0.6470588235, blue: 0.6941176471, alpha: 1)
        
        yourVoteHeaderLabelLeadingConstraint.constant = isSmallIPhone ? 10 : 16
//        othersLabelTrailingConstraint.constant = isSmallIPhone ? 4 : 8
        yourVoteAVGLeadingConstraint.constant = isSmallIPhone ? 2 : 8
        teamVoteAVGLeadingConstraint.constant = isSmallIPhone ? 2 : 8
        
        if isSmallIPhone {
            yourVoteValueLabel.font = UIFont.teambrellaBold(size: 29)
            teamVoteValueLabel.font = UIFont.teambrellaBold(size: 29)
        } else {
            yourVoteValueLabel.font = UIFont.teambrellaBold(size: 34)
            teamVoteValueLabel.font = UIFont.teambrellaBold(size: 34)
        }
        
//        othersLabel.text = "Team.VotingRiskVC.othersButton".localized
    }
    
    @objc
    private func tap(_ button: UIButton) {
//        delegate?.votingRisk(cell: self, didTapButton: button)
    }
    
    func showTeamNoVote(risk: Double?) {
        var show = false
        risk.flatMap { show = $0 >= 5.0 }
        teamVoteValueLabel.isHidden = show
        teamVoteBadgeLabel.isHidden = show
        teamVoteNotAccept.isHidden = !show
        teamVoteNotAccept.text = "Team.Vote.doNotAccept".localized
    }
    
    func showYourNoVote(risk: Double?) {
        var show = false
        risk.flatMap { show = $0 >= 5.0 }
        yourVoteValueLabel.isHidden = show
        yourVoteBadgeLabel.isHidden = risk != nil ? show : true
        yourVoteNotAccept.isHidden = !show
        yourVoteNotAccept.text = "Team.Vote.doNotAccept".localized
    }
}
