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
    func chatObjectWasTapped(view: ChatObjectView)
    func chatObjectVoteShow(view: ChatObjectView)
    func chatObjectVoteHide(view: ChatObjectView)
}

private struct Constant {
    static let smallImageViewSize: CGFloat = 32
    static let normalImageViewSize: CGFloat = 38
    static let claimObjectViewCornerRadius: CGFloat = 3
    static let smallImageViewOffset: CGFloat = 12
    static let normalImageViewOffset: CGFloat = 12
}

class ChatObjectView: UIView, XIBInitable {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var amountLabel: InfoHelpLabel!
    @IBOutlet var currencyLabel: CurrencyLabel!
    
    @IBOutlet var separatorView: UIView!
    
    @IBOutlet var chevronButton: UIButton!
    @IBOutlet var voteContainerTapArea: UIView!
    
    @IBOutlet var voteTitleLabel: InfoLabel!
    @IBOutlet var voteValueLabel: TitleLabel!
    @IBOutlet var percentLabel: UILabel!
    @IBOutlet var proxyAvatarView: RoundImageView!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var rightLabel: BlockHeaderLabel!
    @IBOutlet var bottomSeparator: UIView!
    
    @IBOutlet var imageViewWidth: NSLayoutConstraint!
    @IBOutlet var imageViewHeight: NSLayoutConstraint!
    @IBOutlet var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var voteContainerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var voteButtonContainer: UIView!
    @IBOutlet var voteContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var voteContainer: UIStackView!
    
    var contentView: UIView!
    
    @IBOutlet var chevronImageView: UIImageView!
    
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
    
    func clearLabels() {
        nameLabel.text = ""
        amountLabel.text = ""
        currencyLabel.text = ""
        voteTitleLabel.text = ""
        voteValueLabel.text = ""
        voteValueLabel.text = ""
        percentLabel.text = ""
        rightLabel.text = ""
    }
    
    func initialSetup() {
        voteContainer.spacing = isSmallIPhone ? CGFloat(8) : CGFloat(13)
        voteContainerLeadingConstraint.constant = isSmallIPhone ? CGFloat(8) : CGFloat(13)
        clearLabels()
        chevronButton.isHidden = false
        chevronImageView.isHidden = false
        voteContainer.isHidden = false
        chevronImageView.alpha = 0
        voteContainer.alpha = 1
        voteContainerTapArea.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                         action: #selector(tapContainerTapArea)))
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
        rightButton.isHidden = true
        chevronImageView.alpha = 1
        voteContainer.alpha = 0
        bottomSeparator.isHidden = true
    }
    
    func showVoteContainer() {
        voteContainer.alpha = 1
        rightButton.isHidden = false
        chevronImageView.alpha = 0
        bottomSeparator.isHidden = false
    }
    
    func resizeImageView() {
        imageViewWidth.constant = isSmallIPhone ? Constant.smallImageViewSize : Constant.normalImageViewSize
        imageViewHeight.constant = isSmallIPhone ? Constant.smallImageViewSize : Constant.normalImageViewSize
        imageViewLeadingConstraint.constant = isSmallIPhone ? Constant.smallImageViewOffset :
            Constant.normalImageViewOffset
        voteContainerTrailingConstraint.constant = isSmallIPhone ? Constant.smallImageViewOffset :
            Constant.normalImageViewOffset
    }
    
    // swiftlint:disable:next function_body_length
    private func setupClaimObjectView(basic: ChatModel.BasicPart,
                                      voting: ChatModel.VotingPart?,
                                      team: TeamPart) {
        nameLabel.text = basic.model
        amountLabel.text = basic.claimAmount.map { amount in
            "Team.Chat.ObjectView.ClaimAmountLabel".localized + String(format: "%.2f", amount.value)
        }
        currencyLabel.text = team.currency
        rightLabel.text = "Team.Chat.ObjectView.VoteLabel".localized
        imageView.image = #imageLiteral(resourceName: "imagePlaceholder")
        rightLabel.textColor = #colorLiteral(red: 0.2549019608, green: 0.3058823529, blue: 0.8, alpha: 1)
        basic.smallPhoto.map { self.imageView.showImage(string: $0, needHeaders: true) }
        voteTitleLabel.text = "Team.Chat.ObjectView.TitleLabel".localized
        if let voting = voting {
            if voting.canVote {
                if let vote = voting.myVote {
                    if voting.proxyName != nil {
                        voteValueLabel.text = String(format: "%.f", vote * 100)
                        rightLabel.text = "Team.Chat.ObjectView.VoteLabel".localized
                    } else {
                        voteValueLabel.text = String(format: "%.f", vote * 100)
                        rightLabel.text = "Team.Chat.ObjectView.RevoteLabel".localized
                    }
                    percentLabel.text = "%"
                } else {
                    rightLabel.text = "Team.Chat.ObjectView.VoteLabel".localized
                    voteValueLabel.text = "..."
                    percentLabel.text = ""
                }
            } else {
                voteTitleLabel.text = "Team.Chat.ObjectView.TitleLabel.teamVote".localized
                if let teamVote = voting.ratioVoted {
                    voteValueLabel.text = String.truncatedNumber(teamVote.value * 100)
                } else {
                    voteValueLabel.text = "..."
                }
                rightButton.isHidden = true
                rightLabel.isHidden = true
                voteButtonContainer.isHidden = true
                percentLabel.text = "%"
            }
        } else if let reimbursement = basic.reimbursement {
            voteTitleLabel.text = "Team.Chat.ObjectView.TitleLabel.teamVote".localized
            voteValueLabel.text = String.truncatedNumber(reimbursement * 100)
            rightButton.isHidden = true
            rightLabel.isHidden = true
            voteButtonContainer.isHidden = true
            percentLabel.text = "%"
        }
        percentLabel.font = isSmallIPhone ? UIFont.teambrellaBold(size: 16) : UIFont.teambrellaBold(size: 20)
        proxyAvatarView.image = nil
        resizeImageView()
        imageView.layer.cornerRadius = Constant.claimObjectViewCornerRadius
    }
    
    // swiftlint:disable:next function_body_length
    private func setupTeammateObjectView(basic: ChatModel.BasicPart,
                                         voting: ChatModel.VotingPart?,
                                         team: TeamPart) {
        nameLabel.text = basic.name?.short
        imageView.show(basic.avatar)
        if let model = basic.model, let year = basic.year {
            let yearsString = CoverageLocalizer(type: team.coverageType).yearsString(year: year)
            amountLabel.text = "\(model.uppercased()), \(yearsString)"
        }
        percentLabel.isHidden = true
        currencyLabel.isHidden = true
        rightLabel.textColor = #colorLiteral(red: 0.2549019608, green: 0.3058823529, blue: 0.8, alpha: 1)
        voteValueLabel.font = isSmallIPhone ? UIFont.teambrellaBold(size: 14) : UIFont.teambrellaBold(size: 18)
        if let voting = voting {
            if voting.canVote {
                currencyLabel.text = nil
                voteTitleLabel.text = "Team.Chat.ObjectView.TitleLabel".localized
                if let vote = voting.myVote {
                    if voting.proxyName != nil {
                        voteValueLabel.text = String(format: "%.1f", vote)
                        rightLabel.text = "Team.Chat.ObjectView.VoteLabel".localized
                    } else {
                        voteValueLabel.text = String(format: "%.1f", vote)
                        rightLabel.text = "Team.Chat.ObjectView.RevoteLabel".localized
                    }
                } else {
                    rightLabel.text = "Team.Chat.ObjectView.VoteLabel".localized
                    voteValueLabel.text = "..."
                }
            } else {
                voteTitleLabel.text = "Team.Chat.ObjectView.TitleLabel.teamVote".localized
                if let teamVote = voting.riskVoted {
                    voteValueLabel.text = String.truncatedNumber(teamVote)
                } else {
                    voteValueLabel.text = "..."
                }
                rightButton.isHidden = true
                rightLabel.isHidden = true
                voteButtonContainer.isHidden = true
            }
        } else if let risk = basic.risk {
            voteTitleLabel.text = "Team.Chat.ObjectView.TitleLabel.risk".localized
            voteValueLabel.text = String(format: "%.1f", risk)
            rightButton.isHidden = true
            rightLabel.isHidden = true
            voteButtonContainer.isHidden = true
        }
        resizeImageView()
        imageView.layer.cornerRadius = isSmallIPhone ? Constant.smallImageViewSize / 2
            : Constant.normalImageViewSize / 2
    }

    private func processOpenCloseTap() {
        if !voteButtonContainer.isHidden {
            if chevronImageView.alpha > 0.5 {
                delegate?.chatObjectVoteHide(view: self)
            }
            else {
                delegate?.chatObjectVoteShow(view: self)
            }
        }
        else {
            delegate?.chatObjectWasTapped(view: self)
        }
    }
    
    @objc func tapContainerTapArea(_ sender: UITapGestureRecognizer) {
        processOpenCloseTap()
    }
    
    @IBAction func tapChevron(_ sender: UIButton) {
        processOpenCloseTap()
    }
    
    @IBAction func tapRightButton(_ sender: UIButton) {
        processOpenCloseTap()
    }
    
    @IBAction func tapView(_ sender: UITapGestureRecognizer) {
        delegate?.chatObjectWasTapped(view: self)
    }
    
}
