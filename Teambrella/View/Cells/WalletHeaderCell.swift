//
//  WalletHeaderCell.swift
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

class WalletHeaderCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var amount: WalletAmountLabel!
    @IBOutlet var auxillaryAmount: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var numberBar: NumberBar!
    @IBOutlet var button: BorderedButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CellDecorator.shadow(for: self, opacity: 0.1, radius: 5)
        numberBar.left?.alignmentType = .leading
        numberBar.right?.alignmentType = .leading
    }

}
