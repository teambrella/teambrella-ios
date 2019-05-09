//
//  WalletFundingCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.

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

class WalletFundingCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var headerLabel: Label!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var lowerNumberView: NumberView!
    @IBOutlet var lowerCurrencyLabel: Label!
    @IBOutlet var fundWalletButton: BorderedButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        ViewDecorator.shadow(for: self, opacity: 0.1, radius: 5)
        ViewDecorator.roundedEdges(for: self)
        lowerNumberView.alignmentType = .leading
    }

}
