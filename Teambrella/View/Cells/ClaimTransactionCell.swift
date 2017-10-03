//
//  ClaimTransactionCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 29.08.17.
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
//

import UIKit

class ClaimTransactionCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var container: UIView!
    @IBOutlet var avatar: RoundBadgedView!
    @IBOutlet var nameLabel: MessageTitleLabel!
    @IBOutlet var amountCrypto: InfoHelpLabel!
    @IBOutlet var cryptoAmountLabel: InfoHelpLabel!
    @IBOutlet var amountFiat: InfoHelpLabel!
    @IBOutlet var fiatAmountLabel: InfoHelpLabel!
    @IBOutlet var status: InfoHelpLabel!
    @IBOutlet var statusLabel: InfoHelpLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
