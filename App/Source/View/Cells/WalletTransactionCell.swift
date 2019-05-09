//
//  WalletTransactionCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 01.09.17.
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

class WalletTransactionCell: UICollectionViewCell, XIBInitableCell {

    @IBOutlet var container: UIView!

    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!

    @IBOutlet var signAmount: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var kindLabel: UILabel!

    @IBOutlet weak var separator: UIView!

    func setup(with model: WalletTransactionsCellModel) {
        let currency = service.session?.currentTeam?.currencySymbol ?? ""

        if model.claimID != nil {
            avatarView.showImage(string: model.smallPhoto, needHeaders: true)
            avatarView.layer.cornerRadius = 4
            //nameLabel.text = model.
        } else {
            avatarView.show(model.avatar)
            avatarView.layer.cornerRadius = avatarView.frame.height / 2
        }
        nameLabel.text = model.name
        avatarView.layer.masksToBounds = true
        avatarView.contentMode = .scaleAspectFill
        detailsLabel.text = model.detailsText
        amountLabel.text = model.amountText
        kindLabel.text = model.kindText
        
        let amount = -model.amountFiat.value
        let signMonth: String = amount >= 0.01 ? "+" : amount <= -0.01 ? "-" : ""
        let signMonthColor: UIColor = amount > 0.0 ? .tealish : .lipstick
        signAmount.text = signMonth
        signAmount.textColor = signMonthColor
        amountLabel.text = String(format:"%.2f %@", abs(amount), currency)

        if (abs(model.amountCrypto.value) >= 0.00001) {
            kindLabel.text = String(format: "%.2f mETH", abs(MEth(model.amountCrypto).value))
        }
    }

}
