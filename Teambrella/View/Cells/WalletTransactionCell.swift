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

    @IBOutlet var avatarView: RoundImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!

    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var kindLabel: UILabel!

    @IBOutlet weak var separator: UIView!

    func setup(with model: WalletTransactionsCellModel) {
        avatarView.showAvatar(string: model.avatar)
        nameLabel.text = model.name
        detailsLabel.text = model.detailsText
        amountLabel.text = model.amountText
        kindLabel.text = model.kindText
    }

}
