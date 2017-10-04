//
//  ClaimTransactionsCellBuilder.swift
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

import Foundation

struct ClaimTransactionsCellBuilder {
    static func populate(cell: UICollectionViewCell, with model: ClaimTransactionsCellModel, userID: String) {
        if let cell = cell as? ClaimTransactionCell {
            cell.avatar.showAvatar(string: model.avatarString)
            cell.nameLabel.text = model.name
            guard let session = service.session else { return }
        
            let models = model.to.filter { $0.userID == userID }
            
            let cryptos = models.map { $0.amountCrypto * 1000 }.reduce(0, +)
            let fiats = models.map { $0.amountFiat }.reduce(0, +)
         
            cell.amountCrypto.text = "Team.Claims.ClaimTransactionsVC.amountCrypto".localized
            cell.cryptoAmountLabel.text = String.formattedNumber(cryptos) + " " + session.coinName
            cell.amountFiat.text = "Team.Claims.ClaimTransactionsVC.amountFiat".localized
            cell.fiatAmountLabel.text = String.formattedNumber(fiats) + " " + service.currencySymbol
            
            cell.status.text = "Team.Claims.ClaimTransactionsVC.status".localized
            cell.statusLabel.text = model.status.localizationKey.localized
        }
    }
}
