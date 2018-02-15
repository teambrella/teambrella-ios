//
/* Copyright(C) 2018 Teambrella, Inc.
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

protocol ClaimVotingDelegate: class {
    func claimVoting(view: ClaimVotingView, finishedSliding slider: UISlider)
    func claimVotingDidResetVote(view: ClaimVotingView)
    func claimVotingDidTapTeam(view: ClaimVotingView)
}

class ClaimVotingView: UIView, XIBInitable {
    @IBOutlet var slashView: SlashView!
    
    @IBOutlet var teamVoteLabel: InfoLabel!
    @IBOutlet var teamValueLabel: UILabel!
    @IBOutlet var teamAmountLabel: UILabel!
    @IBOutlet var teamCurrencyLabel: CurrencyLabel!
    @IBOutlet var teamPercentLabel: UILabel!
    @IBOutlet var teamAvatarsStack: RoundImagesStack!
    @IBOutlet var teamButton: UIButton!
    
    @IBOutlet var yourVoteLabel: InfoLabel!
    @IBOutlet var yourValueLabel: UILabel!
    @IBOutlet var yourAmountLabel: UILabel!
    @IBOutlet var yourCurrencyLabel: CurrencyLabel!
    @IBOutlet var byProxyLabel: InfoLabel!
    @IBOutlet var proxyAvatarView: RoundImageView!
    @IBOutlet var yourPercentLabel: UILabel!
    @IBOutlet var resetVoteButton: UIButton!
    
    @IBOutlet var slider: UISlider!

    var teamVote: ClaimVote?
    var yourVote: ClaimVote?
    var claimAmount: Fiat?

    var proxyVote: ClaimVote?
    var proxyAvatar: Avatar?
    var otherAvatars: [Avatar]?
    var otherCount: Int = 0

    var contentView: UIView!

    var session: Session?
    weak var delegate: ClaimVotingDelegate?

    var isYourVoteHidden: Bool = false {
        didSet {
            yourAmountLabel.isHidden = isYourVoteHidden
            yourPercentLabel.isHidden = isYourVoteHidden
            yourCurrencyLabel.isHidden = isYourVoteHidden
        }
    }

    var isChangingVote: Bool = false {
        didSet {
            if isChangingVote == oldValue { return }

            let alpha: CGFloat = isChangingVote ? 0.5 : 1
            UIView.animate(withDuration: 0.3) {
                self.yourValueLabel.alpha = alpha
                self.yourAmountLabel.alpha = alpha
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        initialSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
         initialSetup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func initialSetup() {
        slashView.layer.cornerRadius = 5
        slashView.layer.masksToBounds = true
        slashView.layer.borderWidth = 1
        slashView.layer.borderColor = #colorLiteral(red: 0.9333333333, green: 0.9607843137, blue: 1, alpha: 1).cgColor

        slider.minimumValue = 0
        slider.maximumValue = 1
        setup()
    }

    func setup(with claim: ClaimEntityLarge?) {
        guard let voting = claim?.voting else { return }

        claimAmount = claim?.basic.claimAmount
        teamVote = voting.ratioVoted
        yourVote = voting.myVote
        proxyVote = voting.proxyVote
        proxyAvatar = voting.proxyAvatar

        otherAvatars = voting.otherAvatars
        otherCount = voting.otherCount
        setup()
    }

    func setup(with chatModel: ChatModel?) {
        guard let chatModel = chatModel else { return }

        teamVote = chatModel.voting?.ratioVoted
        let hasProxy = chatModel.voting?.proxyAvatar != nil
        let vote = chatModel.voting?.myVote.map { ClaimVote($0) }

        claimAmount = chatModel.basic?.claimAmount
        yourVote = hasProxy ? nil : vote
        proxyVote = hasProxy ? vote : nil
        proxyAvatar = chatModel.voting?.proxyAvatar
        otherAvatars = chatModel.voting?.otherAvatars
        otherCount = chatModel.voting?.otherCount ?? 0
        setup()
    }

    @IBAction func slide(_ sender: UISlider, event: UIEvent) {
        isChangingVote = true
        yourVote = ClaimVote(sender.value)
        setup()
        if let touch = event.allTouches?.first, touch.phase == .ended {
            delegate?.claimVoting(view: self, finishedSliding: sender)
        }
    }

    @IBAction func tapResetVote(_ sender: UIButton) {
        yourVote = nil
        setup()
        delegate?.claimVotingDidResetVote(view: self)
    }

    @IBAction func tapTeam(_ sender: UIButton) {
        delegate?.claimVotingDidTapTeam(view: self)
    }

    private func setup() {
        teamVoteLabel.text = "Team.ClaimCell.teamVote".localized.uppercased()
        teamCurrencyLabel.text = session?.currentTeam?.currency

        yourVoteLabel.text = "Team.ClaimCell.yourVote".localized.uppercased()
        yourCurrencyLabel.text = session?.currentTeam?.currency

        setupYourView()
        guard let claimAmount = claimAmount else { return }

        if let teamVote = teamVote {
            teamValueLabel.text = String.truncatedNumber(teamVote.percentage)
            teamAmountLabel.text = String.truncatedNumber(teamVote.fiat(from: claimAmount).value)
        }

        let vote: ClaimVote? = yourVote ?? proxyVote
        if let vote = vote {
            isYourVoteHidden = false
            yourValueLabel.text = String.truncatedNumber(vote.percentage)
            yourAmountLabel.text = String.truncatedNumber(vote.fiat(from: claimAmount).value)
            slider.setValue(Float(vote.value), animated: true)
        }

        if yourVote == nil, let proxyAvatar = proxyAvatar {
            proxyAvatarView.show(proxyAvatar)
            byProxyLabel.text = "Team.ClaimCell.byProxy".localized.uppercased()
        }

        resetVoteButton.setTitle("Team.ClaimCell.resetVote".localized, for: .normal)

        presentAvatars()

    }

    private func setupYourView() {
        resetVoteButton.isHidden = yourVote == nil
        proxyAvatarView.isHidden = proxyAvatar == nil || yourVote != nil
        byProxyLabel.isHidden = proxyVote == nil || yourVote != nil

        if yourVote == nil && proxyVote == nil {
            yourValueLabel.text = ". . ."
            isYourVoteHidden = true
            slider.setValue(slider.minimumValue, animated: true)
        }
    }

    private func presentAvatars() {
        guard let avatars = otherAvatars else { return }

        let urls = avatars.flatMap { $0.url }
        let maxAvatarsStackCount = 4
        let otherVotersCount = otherCount - maxAvatarsStackCount + 1
        let label: String?  =  otherCount > 0 ? "+\(otherVotersCount)" : nil
        teamAvatarsStack.set(images: urls, label: label, max: maxAvatarsStackCount)
    }

}
