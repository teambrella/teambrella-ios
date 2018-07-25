//
//  CompactUserInfoHeader.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 15.07.17.

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

class CompactUserInfoHeader: UIView, XIBInitable, AmountUpdatable {
    @IBOutlet var contentView: UIView!
    @IBOutlet var leftNumberView: NumberView!
    @IBOutlet var rightNumberView: NumberView!
    @IBOutlet var avatarView: RoundImageView!
    @IBOutlet var radarView: RadarView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        leftNumberView.badgeLabel.text = ""
        leftNumberView.titleLabel.text = ""
        leftNumberView.amountLabel.text = ""
        leftNumberView.percentLabel.text = ""
        leftNumberView.currencyLabel.text = ""
        rightNumberView.badgeLabel.text = ""
        rightNumberView.titleLabel.text = ""
        rightNumberView.amountLabel.text = ""
        rightNumberView.percentLabel.text = ""
        rightNumberView.currencyLabel.text = ""
    }
}
