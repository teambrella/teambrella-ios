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

protocol ChatObjectViewDelegate: class {
    func chatObject(view: ChatObjectView, didTap button: UIButton)
    func chatObjectWasTapped(view: ChatObjectView)
}

class ChatObjectView: UIView, XIBInitable {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var amountLabel: InfoHelpLabel!
    @IBOutlet var currencyLabel: CurrencyLabel!
    
    @IBOutlet var separatorView: UIView!
    
    @IBOutlet var chevronButton: UIButton!
    @IBOutlet var voteContainer: UIView!
    
    @IBOutlet var voteTitleLabel: InfoLabel!
    @IBOutlet var voteValueLabel: TitleLabel!
    @IBOutlet var percentLabel: UILabel!
    @IBOutlet var proxyAvatarView: RoundImageView!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var rightLabel: BlockHeaderLabel!
    
    var contentView: UIView!
    
    weak var delegate: ChatObjectViewDelegate?
    
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
        chevronButton.isHidden = false
        voteContainer.isHidden = false
        chevronButton.alpha = 0
        voteContainer.alpha = 1
        
        chevronButton.imageView?.contentMode = .scaleAspectFit
        chevronButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func setup(with chatModel: ChatModel?) {
        guard let model = chatModel else { return }
        guard let teamPart = model.team else { return }
        
        if let basic = model.basic, basic.claimAmount != nil {
            setupClaimObjectView(basic: basic,
                                 voting: model.voting,
                                 team: teamPart)
        } else if let basic = model.basic {
            setupTeammateObjectView(basic: basic,
                                    voting: model.voting,
                                    team: teamPart)
        }
    }
    
    func showChevron() {
        chevronButton.alpha = 1
        voteContainer.alpha = 0
    }
    
    func showVoteContainer() {
        voteContainer.alpha = 1
        chevronButton.alpha = 0
    }
    
    private func setupClaimObjectView(basic: ChatModel.BasicPart,
                                      voting: ChatModel.VotingPart?,
                                      team: TeamPart) {
        nameLabel.text = basic.model
        amountLabel.text = basic.claimAmount.map { amount in
            "Team.Chat.ObjectView.ClaimAmountLabel".localized + String(format: "%.2f", amount.value)
        }
        currencyLabel.text = team.currency
        percentLabel.text = "%"
        rightLabel.text = "Team.Chat.ObjectView.VoteLabel".localized
        
        imageView.image = #imageLiteral(resourceName: "imagePlaceholder")
        imageView.layer.cornerRadius = 4
        rightLabel.textColor = #colorLiteral(red: 0.2549019608, green: 0.3058823529, blue: 0.8, alpha: 1)
        basic.smallPhoto.map { self.imageView.showImage(string: $0) }
        voteTitleLabel.text = "Team.Chat.ObjectView.TitleLabel".localized
        if let voting = voting {
            if let vote = voting.myVote {
                if voting.proxyName != nil {
                    voteValueLabel.text = String(format: "%.f", vote * 100)
                    rightLabel.text = "Team.Chat.ObjectView.VoteLabel".localized
                } else {
                    voteValueLabel.text = String(format: "%.f", vote * 100)
                    rightLabel.text = "Team.Chat.ObjectView.RevoteLabel".localized
                }
            } else {
                rightLabel.text = "Team.Chat.ObjectView.VoteLabel".localized
                voteValueLabel.text = "..."
            }
        } else if let reimbursement = basic.reimbursement {
            voteTitleLabel.text = "Team.Chat.ObjectView.TitleLabel.team".localized
            voteValueLabel.text = String.truncatedNumber(reimbursement * 100)
            rightButton.isHidden = true
            rightLabel.isHidden = true
        }
        proxyAvatarView.image = nil
    }
    
    private func setupTeammateObjectView(basic: ChatModel.BasicPart,
                                         voting: ChatModel.VotingPart?,
                                         team: TeamPart) {
        nameLabel.text = basic.name?.short
        imageView.showImage(string: basic.avatar)
        imageView.layer.cornerRadius = imageView.frame.width / 2
        if let model = basic.model, let year = basic.year, let team = service.session?.currentTeam {
            amountLabel.text = "\(model.uppercased()), \(year.localizedString(for: team.coverageType))"
        }
        percentLabel.isHidden = true
        currencyLabel.isHidden = true
        rightLabel.textColor = #colorLiteral(red: 0.2549019608, green: 0.3058823529, blue: 0.8, alpha: 1)
        
        if let voting = voting {
            currencyLabel.text = nil
            voteTitleLabel.text = "Team.Chat.ObjectView.TitleLabel".localized
            if let vote = voting.myVote {
                if voting.proxyName != nil {
                    voteValueLabel.text = String(format: "%.2f", vote)
                    rightLabel.text = "Team.Chat.ObjectView.VoteLabel".localized
                } else {
                    voteValueLabel.text = String(format: "%.2f", vote)
                    rightLabel.text = "Team.Chat.ObjectView.RevoteLabel".localized
                }
            } else {
                rightLabel.text = "Team.Chat.ObjectView.VoteLabel".localized
                voteValueLabel.text = "..."
            }
        } else if let risk = basic.risk {
            voteTitleLabel.text = "Team.Chat.ObjectView.TitleLabel.risk".localized
            voteValueLabel.text = String.truncatedNumber(risk)
            rightButton.isHidden = true
            rightLabel.isHidden = true
        }
    }
    
    @IBAction func tapChevron(_ sender: UIButton) {
        delegate?.chatObject(view: self, didTap: sender)
    }
    
    @IBAction func tapRightButton(_ sender: UIButton) {
        delegate?.chatObject(view: self, didTap: sender)
    }
    
    @IBAction func tapView(_ sender: UITapGestureRecognizer) {
        delegate?.chatObjectWasTapped(view: self)
    }
    
}
