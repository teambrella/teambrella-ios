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
    
    @IBOutlet var yourVoteOffsetConstraint: NSLayoutConstraint!
    
    //    var riskScale: RiskScaleEntity? {
    //        didSet {
    //            updateWithRiskScale()
    //        }
    //    }
    var teammate: TeammateLike? {
        didSet {
            updateWithTeammate()
        }
    }
    
    // Risk value changed
    var onVoteUpdate: ((Double) -> Void)?
    var onVoteConfirmed: ((Double?) -> Void)?
    
    var votingScroller: VotingScrollerVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        votingRisksView.layer.cornerRadius = 4
        votingRisksView.layer.borderColor = #colorLiteral(red: 0.9411764706, green: 0.9647058824, blue: 1, alpha: 1).cgColor
        votingRisksView.layer.borderWidth = 1
        //yourVoteOffsetConstraint.constant = votingRisksView.bounds.midX
        // Do any additional setup after loading the view.
        leftLabeledView.isHidden = true
        rightLabeledView.isHidden = true
        votingRiskLabel.text = "Team.VotingRiskVC.headerLabel".localized
        teamVoteLabel.text = "Team.VotingRiskVC.numberBar.left".localized
        yourVoteLabel.text = "Team.VotingRiskVC.numberBar.right".localized
        teamAverage.text = "Team.VotingRiskVC.avgLabel".localized("-60") //
        yourAverage.text = "Team.VotingRiskVC.avgLabel".localized("+14") //
        resetVoteButton.setTitle("Team.VotingRiskVC.resetVoteButton".localized, for: .normal)
        seeOthersButton.setTitle("Team.VotingRiskVC.othersButton", for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //votingScroller.scrollToTeamAverage()
        guard let vote = teammate?.extended?.voting?.myVote, let scroller = votingScroller else { return }
        
        //votingScroller.scrollTo(offset: offsetFrom(risk: vote, in: scroller))
    }
    
    func updateWithTeammate() {
        guard let teammate = teammate else { return }
        
        mainLabeledView.avatar.showAvatar(string: teammate.avatar)
        update(voting: teammate.extended?.voting)
        guard let riskScale = teammate.extended?.riskScale else { return }
        
        votingScroller.updateWithRiskScale(riskScale: riskScale)
        mainLabeledView.riskLabelText = String(format:"%.2f", riskScale.myRisk)
    }
    
    func update(voting: TeammateVotingInfo?) {
        guard let voting = voting else { return }
        
        let label: String? = voting.votersCount > 0 ? String(voting.votersCount) : nil
        avatarsStackView.setAvatars(images: voting.votersAvatars,
                                    label: label,
                                    max: nil)
        
        if let risk = voting.riskVoted {
            teamRiskValue.text = String.formattedNumber(double: risk)
        }
    }
    
    func updateRiskDeltas(risk: Double) {
        func text(for label: UILabel, risk: Double?) {
            guard let riskScale = teammate?.extended?.riskScale else { return }
            guard let risk = risk else { return }
            
            let delta = riskScale.averageRisk - risk
            var text = "AVG\n"
            text += delta > 0 ? "+" : ""
            let percent = delta / riskScale.averageRisk * 100
            let amount = String(format: "%.0f", percent)
            label.text =  text + amount + "%"
        }
        
        text(for: yourAverage, risk: risk)
        text(for: teamAverage, risk: teammate?.extended?.voting?.riskVoted)
    }
    
    func updateAvatars(range: RiskScaleEntity.Range) {
        func setview(labeledView: LabeledRoundImageView, with teammate: RiskScaleEntity.Teammate?) {
            guard let teammate = teammate else {
                labeledView.isHidden = true
                labeledView.avatar.image = nil
                return
            }
            
            if labeledView.avatar.image != nil {
                let oldImageView = RoundImageView(frame: labeledView.avatar.frame)
                oldImageView.contentMode = labeledView.avatar.contentMode
                oldImageView.image = labeledView.avatar.image
                labeledView.insertSubview(oldImageView, belowSubview: labeledView.riskLabel)
                labeledView.isHidden = false
                labeledView.avatar.alpha = 0
                labeledView.avatar.showAvatar(string: teammate.avatar) { image, error in
                    //                guard let image = image else { return }
                    labeledView.avatar.image = image
                    UIView.animate(withDuration: 0.3, animations: {
                        oldImageView.alpha = 0
                        labeledView.avatar.alpha = 1
                    }, completion: { completed in
                        oldImageView.removeFromSuperview()
                    })
                    
                }
            } else {
                labeledView.isHidden = false
                labeledView.avatar.showAvatar(string: teammate.avatar)
            }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToVotingScroller", let vc = segue.destination as? VotingScrollerVC {
            votingScroller = vc
            vc.delegate = self
        }
    }
    
    func riskFrom(controller: VotingScrollerVC, offset: CGFloat) -> Double {
        return min(Double(pow(25, offset / controller.maxValue) / 5), 5)
    }
    
    func offsetFrom(risk: Double, in controller: VotingScrollerVC) -> CGFloat {
        return CGFloat(log(base: 25, value: pow(risk * 5, Double(controller.maxValue))))
    }
    
    @IBAction func tapResetVote(_ sender: UIButton) {
        onVoteConfirmed?(nil)
        teamVoteLabel.text = "..."
        if let proxyVote = teammate?.extended?.voting?.proxyVote {
            let offset = offsetFrom(risk: proxyVote, in: votingScroller)
            votingScroller.scrollTo(offset: offset)
        } else {
            votingScroller.scrollToTeamAverage()
        }
    }
    
}

extension VotingRiskVC: VotingScrollerDelegate {
    
    func votingScroller(controller: VotingScrollerVC, didChange value: CGFloat) {
        let risk = riskFrom(controller: controller, offset: value)
        yourRiskValue.text = String(format: "%.2f", risk)
        updateRiskDeltas(risk: risk)
        onVoteUpdate?(risk)
        print("new value \(value)")
    }
    
    func votingScroller(controller: VotingScrollerVC, middleCellRow: Int) {
        guard let range = teammate?.extended?.riskScale?.ranges[middleCellRow] else { return }
        
        print("voting scroller middle cell row is now: \(middleCellRow)")
        updateAvatars(range: range)
    }
    
    func votingScroller(controller: VotingScrollerVC, didSelect value: CGFloat) {
        onVoteConfirmed?(riskFrom(controller: controller, offset: value))
    }
}
