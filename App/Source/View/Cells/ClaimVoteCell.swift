//
//  ClaimVoteCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.

/* Copyright(C) 2017  Teambrella, Inc.
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

class ClaimVoteCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var titleLabel: Label!
    @IBOutlet var remainingDaysLabel: ThinStatusSubtitleLabel!
    @IBOutlet var pieChart: PieChartView!
    @IBOutlet var infoButton: UIButton!
    
    @IBOutlet var slashView: SlashView!
    
    @IBOutlet var yourVoteLabel: Label!
    @IBOutlet var yourVotePercentValue: UILabel!
    @IBOutlet var yourVoteAmount: UILabel!
    @IBOutlet var yourVoteCurrency: Label!
    @IBOutlet var yourVotePercentSign: UILabel!
    
    @IBOutlet var byProxyLabel: Label!
    @IBOutlet var proxyAvatar: RoundImageView!
    
    @IBOutlet var teamVoteLabel: Label!
    @IBOutlet var teamVotePercentValue: UILabel!
    @IBOutlet var teamVoteAmount: UILabel!
    @IBOutlet var teamVoteCurrency: Label!
    @IBOutlet var teamVotePercentSign: UILabel!
    @IBOutlet var avatarsStack: RoundImagesStack!
    
    @IBOutlet var slider: UISlider!
    
    @IBOutlet var submitButton: PlainButton!
    @IBOutlet var resetButton: UIButton!
    
    @IBOutlet var othersVotedButton: UIButton!
    
    var isYourVoteHidden: Bool = false {
        didSet {
            yourVoteAmount.isHidden = isYourVoteHidden
            yourVotePercentSign.isHidden = isYourVoteHidden
            yourVoteCurrency.isHidden = isYourVoteHidden
        }
    }
    
    var isTeamVoteHidden: Bool = false {
        didSet {
            teamVoteAmount.isHidden = isTeamVoteHidden
            teamVotePercentSign.isHidden = isTeamVoteHidden
            teamVoteCurrency.isHidden = isTeamVoteHidden
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        slashView.layer.cornerRadius = 5
        slashView.layer.masksToBounds = true
        slashView.layer.borderWidth = 1
        slashView.layer.borderColor = #colorLiteral(red: 0.9333333333, green: 0.9607843137, blue: 1, alpha: 1).cgColor

        slider.minimumValue = 0
        slider.maximumValue = 1

        pieChart.startAngle = 0
    }

}
