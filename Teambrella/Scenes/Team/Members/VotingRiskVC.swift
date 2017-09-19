//
//  VotingRiskVC.swift
//  Scroller
//
//  Created by Екатерина Рыжова on 29.06.17.
//  Copyright © 2017 Екатерина Рыжова. All rights reserved.
//

import UIKit

class VotingRiskVC: UIViewController {
    @IBOutlet var votingRiskLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var votingRisksView: UIView!
    @IBOutlet var teamVoteLabel: UILabel!
    @IBOutlet var yourVoteLabel: UILabel!
    @IBOutlet var teamRiskValue: UILabel!
    @IBOutlet var yourRiskValue: UILabel!
    @IBOutlet var teamAverage: UILabel!
    @IBOutlet var yourAverage: UILabel!
    @IBOutlet var avatarsStackView: RoundImagesStack!
    @IBOutlet var resetVoteButton: UIButton!
    @IBOutlet var seeOthersButton: UIButton!
    @IBOutlet var leftLabeledView: LabeledRoundImageView!
    @IBOutlet var rightLabeledView: LabeledRoundImageView!
    @IBOutlet var mainLabeledView: LabeledRoundImageView!
    @IBOutlet var yourProxyContainer: UIStackView!
    @IBOutlet var proxyAvatar: RoundImageView!
    @IBOutlet var proxyName: InfoLabel!
    
    @IBOutlet var yourVoteOffsetConstraint: NSLayoutConstraint!
    
    var teammate: ExtendedTeammateEntity? {
        didSet {
            updateWithTeammate()
        }
    }
    
    // Risk value changed
    var onVoteUpdate: ((Double) -> Void)?
    var onVoteConfirmed: ((Double?) -> Void)?
    var isScrollerSet: Bool = false
    
    var votingScroller: VotingScrollerVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        votingRisksView.layer.cornerRadius = 4
        votingRisksView.layer.borderColor = #colorLiteral(red: 0.9411764706, green: 0.9647058824, blue: 1, alpha: 1).cgColor
        votingRisksView.layer.borderWidth = 1

        leftLabeledView.isHidden = true
        rightLabeledView.isHidden = true
        votingRiskLabel.text = "Team.VotingRiskVC.headerLabel".localized
        teamVoteLabel.text = "Team.VotingRiskVC.numberBar.left".localized
        yourVoteLabel.text = "Team.VotingRiskVC.numberBar.right".localized
        teamAverage.text = "Team.VotingRiskVC.avgLabel".localized(-60) //
        yourAverage.text = "Team.VotingRiskVC.avgLabel".localized(14) //
        resetVoteButton.setTitle("Team.VotingRiskVC.resetVoteButton".localized, for: .normal)
        seeOthersButton.setTitle("Team.VotingRiskVC.othersButton".localized, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateWithTeammate()
    }
    
    func updateWithTeammate() {
        guard let teammate = teammate else { return }
        
        mainLabeledView.avatar.showAvatar(string: teammate.basic.avatar)
        update(voting: teammate.voting)
        guard let riskScale = teammate.riskScale else { return }
        
        votingScroller?.updateWithRiskScale(riskScale: riskScale)
        mainLabeledView.riskLabelText = String(format:"%.2f", riskScale.myRisk)
    }
    
    func update(voting: TeammateVotingInfo?) {
        guard let voting = voting else { return }
        
        let label: String? = voting.votersCount > 0 ? String(voting.votersCount) : nil
        avatarsStackView.setAvatars(images: voting.votersAvatars,
                                    label: label,
                                    max: nil)
        
        if let risk = voting.riskVoted {
            teamRiskValue.text = String.formattedNumber(risk)
            updateRiskDeltas(risk: risk)
        }
        
        if let myVote = voting.myVote, let scroller = votingScroller {
            yourRiskValue.text = String(format:"%.2f", myVote)
            let offset = offsetFrom(risk: myVote, in: scroller)
            votingScroller?.scrollTo(offset: offset)
        }
        
        let timeString = DateProcessor().stringFromNow(minutes: voting.remainingMinutes).uppercased()
        timeLabel.text = "Team.VotingRiskVC.ends".localized(timeString)
    }
    
    func updateRiskDeltas(risk: Double) {
        func text(for label: UILabel, risk: Double?) {
            guard let riskScale = teammate?.riskScale else { return }
            guard let risk = risk else { return }
            
            let delta = risk - riskScale.averageRisk
            var text = "AVG\n"
            text += delta > 0 ? "+" : ""
            let percent = delta / riskScale.averageRisk * 100
            let amount = String(format: "%.0f", percent)
            label.text =  text + amount + "%"
        }
        
        text(for: yourAverage, risk: risk)
        text(for: teamAverage, risk: teammate?.voting?.riskVoted)
        mainLabeledView.riskLabelText = String.formattedNumber(risk)
    }
    
    func updateAvatars(range: RiskScaleEntity.Range) {
        func setview(labeledView: LabeledRoundImageView, with teammate: RiskScaleEntity.Teammate?) {
            guard let teammate = teammate else {
                labeledView.isHidden = true
                labeledView.avatar.image = nil
                return
            }
            
            labeledView.isHidden = false
            labeledView.avatar.showAvatar(string: teammate.avatar,
                                          options: [.transition(.fade(0.5)), .forceTransition])
            labeledView.riskLabelText = String(format: "%.2f", teammate.risk)
            labeledView.labelBackgroundColor = .blueWithAHintOfPurple
        }
        
        if range.teammates.count > 1 {
            setview(labeledView: rightLabeledView, with: range.teammates.last)
        } else {
            rightLabeledView.isHidden = true
        }
        setview(labeledView: leftLabeledView, with: range.teammates.first)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToVotingScroller", let vc = segue.destination as? VotingScrollerVC {
            votingScroller = vc
            vc.delegate = self
        }
        if segue.identifier == "ToCompareTeamRisk", let vc = segue.destination as? CompareTeamRiskVC {
            guard let riskScale = teammate?.riskScale else { return }
            
            vc.ranges = riskScale.ranges
        }
    }
    
    func riskFrom(controller: VotingScrollerVC, offset: CGFloat) -> Double {
        return min(Double(pow(25, offset / controller.maxValue) / 5), 5)
    }
    
    func offsetFrom(risk: Double, in controller: VotingScrollerVC) -> CGFloat {
        return CGFloat(log(base: 25.0, value: risk * 5.0)) * controller.maxValue
    }
    
    @IBAction func tapResetVote(_ sender: UIButton) {
        onVoteConfirmed?(nil)
        yourRiskValue.text = "..."
    }
    
    func resetVote() {
        guard let votingScroller = votingScroller else { return }
        
        if let vote = teammate?.voting?.myVote,
            let proxyAvatar = teammate?.voting?.proxyAvatar,
            let proxyName = teammate?.voting?.proxyName {
            yourProxyContainer.isHidden = false
            resetVoteButton.isHidden = true
            self.proxyAvatar.showAvatar(string: proxyAvatar)
            self.proxyName.text = proxyName.uppercased()
            let offset = offsetFrom(risk: vote, in: votingScroller)
            votingScroller.scrollTo(offset: offset)
        } else {
            hideProxy()
            yourRiskValue.text = "..."
            votingScroller.scrollToTeamAverage()
        }
    }
    
    func hideProxy() {
        yourProxyContainer.isHidden = true
        resetVoteButton.isHidden = false
    }
    
    @IBAction func tapOthers(_ sender: UIButton) {
        // segue
    }
    
}

extension VotingRiskVC: VotingScrollerDelegate {
    
    func votingScroller(controller: VotingScrollerVC, didChange value: CGFloat) {
        let risk = riskFrom(controller: controller, offset: value)
        yourRiskValue.text = String(format: "%.2f", risk)
        updateRiskDeltas(risk: risk)
        onVoteUpdate?(risk)
    }
    
    func votingScroller(controller: VotingScrollerVC, middleCellRow: Int) {
        guard let range = teammate?.riskScale?.ranges[middleCellRow] else { return }
        
        updateAvatars(range: range)
    }
    
    func votingScroller(controller: VotingScrollerVC, didSelect value: CGFloat) {
        onVoteConfirmed?(riskFrom(controller: controller, offset: value))
    }
    
    func votingScrollerViewDidAppear(controller: VotingScrollerVC) {
        if isScrollerSet == false {
            controller.scrollToTeamAverage(animated: false)
            isScrollerSet = true
        }
    }
}
