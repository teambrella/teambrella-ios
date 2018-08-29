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

protocol VotingOrVotedRiskCell: XIBInitableCell {
    var titleLabel: BlockHeaderLabel! { get set }
    var timeLabel: ThinStatusSubtitleLabel! { get set }
    var pieChart: PieChartView! { get set }
    
    var slashView: SlashView! { get set }
    var teamVoteHeaderLabel: InfoLabel! { get set }
    var teamVoteValueLabel: AmountLabel! { get set }
    var teamVoteBadgeLabel: BadgeLabel! { get set }
    var teamVoteNotAccept: AmountLabel! { get set }
    var teammatesAvatarStack: RoundImagesStack! { get set }
    
    var yourVoteHeaderLabel: InfoLabel! { get set }
    var yourVoteValueLabel: AmountLabel! { get set }
    var yourVoteBadgeLabel: BadgeLabel! { get set }
    var yourVoteNotAccept: AmountLabel! { get set }
    
    var proxyAvatarView: RoundImageView! { get set }
    var proxyNameLabel: InfoLabel! { get set }
    var isProxyHidden: Bool { get set }
    var currentRisk: Double { get }
    
    func showTeamNoVote(risk: Double?)
    func showYourNoVote(risk: Double?)
}

class VotedRiskCell: UICollectionViewCell, VotingOrVotedRiskCell {
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
    @IBOutlet var othersVotesButton: UIButton!
    @IBOutlet var pieChartLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet var yourVoteHeaderLabelLeadingConstraint: NSLayoutConstraint!
    
    private var dataSource: VotingScrollerDataSource = VotingScrollerDataSource()
    
    weak var delegate: VotingRiskCellDelegate?
    
    var isProxyHidden: Bool = true {
        didSet {
            proxyAvatarView.isHidden = isProxyHidden
            proxyNameLabel.isHidden = isProxyHidden
        }
    }
    
    var currentRisk: Double = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLabels()
        setupButtons()
        
        slashView.layer.cornerRadius = 4
        slashView.layer.borderColor = #colorLiteral(red: 0.9333333333, green: 0.9607843137, blue: 1, alpha: 1).cgColor
        slashView.layer.borderWidth = 1
        
        self.clipsToBounds = true
        ViewDecorator.roundedEdges(for: self)
        ViewDecorator.shadow(for: self)
    }
    
    private func setupButtons() {
        othersVotesButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
    }
    
    private func setupLabels() {
        teamVoteHeaderLabel.text = "Team.VotingRiskVC.numberBar.left".localized
        teamVoteBadgeLabel.text = "Team.VotingRiskVC.avgLabel".localized(0)
        teamVoteBadgeLabel.backgroundColor = #colorLiteral(red: 0.5843137255, green: 0.6470588235, blue: 0.6941176471, alpha: 1)
        
        yourVoteHeaderLabel.text = "Team.VotingRiskVC.numberBar.right".localized
        yourVoteBadgeLabel.text = "Team.VotingRiskVC.avgLabel".localized(0)
        yourVoteBadgeLabel.backgroundColor = #colorLiteral(red: 0.5843137255, green: 0.6470588235, blue: 0.6941176471, alpha: 1)
        
        yourVoteHeaderLabelLeadingConstraint.constant = isSmallIPhone ? 10 : 16
        
        if isSmallIPhone {
            yourVoteValueLabel.font = UIFont.teambrellaBold(size: 29)
            teamVoteValueLabel.font = UIFont.teambrellaBold(size: 29)
        } else {
            yourVoteValueLabel.font = UIFont.teambrellaBold(size: 34)
            teamVoteValueLabel.font = UIFont.teambrellaBold(size: 34)
        }
    }
    
    @objc
    private func tap(_ button: UIButton) {
        delegate?.votingRisk(cell: self, didTapButton: button)
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
    
    func setCurrentRisk(risk: Double?) {
        if let risk = risk {
            currentRisk = risk
        }
    }
}
