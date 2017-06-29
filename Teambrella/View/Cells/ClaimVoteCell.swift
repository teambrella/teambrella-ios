//
//  ClaimVoteCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ClaimVoteCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var titleLabel: Label!
    @IBOutlet var remainingDaysLabel: Label!
    @IBOutlet var pieChart: PieChartView!
    @IBOutlet var infoButton: UIButton!

    @IBOutlet var yourVoteLabel: Label!
    @IBOutlet var yourVotePercentValue: UILabel!
    @IBOutlet var yourVoteAmount: UILabel!
    @IBOutlet var yourVoteCurrency: Label!
    @IBOutlet var byProxyLabel: Label!
    @IBOutlet var proxyAvatar: UIImageView!
    
    @IBOutlet var teamVoteLabel: Label!
    @IBOutlet var teamVotePercentValue: UILabel!
    @IBOutlet var teamVoteAmount: UILabel!
    @IBOutlet var teamVoteCurrency: Label!
    @IBOutlet var avatarsStack: RoundImagesStack!
    
    @IBOutlet var slider: UISlider!
    
    @IBOutlet var submitButton: PlainButton!
    @IBOutlet var resetButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
