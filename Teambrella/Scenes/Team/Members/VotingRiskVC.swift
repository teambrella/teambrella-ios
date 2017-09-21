//
//  VotingRiskVC.swift
//  Scroller
//
//  Created by Екатерина Рыжова on 29.06.17.
//  Copyright © 2017 Екатерина Рыжова. All rights reserved.
//

import UIKit
/*
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
*/
