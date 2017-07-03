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
    @IBOutlet var centralLabeledView: LabeledRoundImageView!
    @IBOutlet var rightLabeledView: LabeledRoundImageView!
    @IBOutlet var mainLabeledView: LabeledRoundImageView!
    
    @IBOutlet var yourVoteOffsetConstraint: NSLayoutConstraint!
    var riskScale: RiskScaleEntity? {
        didSet {
        updateWithRisk()
        }
    }
    
    var votingScroller: VotingScrollerVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        votingRisksView.layer.cornerRadius = 4
        votingRisksView.layer.borderColor = #colorLiteral(red: 0.9411764706, green: 0.9647058824, blue: 1, alpha: 1).cgColor
        votingRisksView.layer.borderWidth = 1
        //yourVoteOffsetConstraint.constant = votingRisksView.bounds.midX
        // Do any additional setup after loading the view.
        if let url = URL(string: "http://testimage.jpg") {
            avatarsStackView.set(images: [url], label: nil, max: 4)
        }
        
    }
    
    func updateWithRisk() {
        guard let riskScale = riskScale else { return }
        
        
        
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
    
}

extension VotingRiskVC: VotingScrollerDelegate {
    func votingScroller(controller: VotingScrollerVC, didChange value: CGFloat) {
        let risk = pow(25, value / controller.maxValue) / 5
        yourRiskValue.text = String(format: "%.2f", risk)
        print("new value \(value)")
    }
}
