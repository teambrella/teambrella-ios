//
//  WalletTransactionsCellBuilder.swift
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

import Foundation

struct WalletTransactionsCellBuilder {
    static func populate(cell: UICollectionViewCell, with model: WalletTransactionsCellModel) {
        if let cell = cell as? WalletTransactionCell {
            guard let date = model.dateCreated else { return }
            
            cell.createdLabel.text = DateFormatter.teambrellaShort.string(from: date)
            let names = model.to.map { $0.name }
            var namesString = ""
            var idx = 1
            for name in names {
                let separator = (idx != names.count) ? ", " : ""
                namesString += String(describing: name) + separator
                idx += 1
            }
            cell.nameLabel.text = namesString
            cell.amountTitle.text = "Me.WalletVC.WalletTransactionsVC.amountTitle".localized
            guard let session = service.session else { return }
            
            let amounts = model.to.map { $0.amount * 1000 }
            var amountString = ""
            idx = 1
            for amount in amounts {
                let isLast: Bool = idx == amounts.count
                let separator = isLast ? "" : ", "
                amountString += String.formattedNumber(amount) + separator
                idx += 1
            }
            cell.amountLabel.text = amountString + " " + session.coinName
            
            cell.kindTitle.text = "Me.WalletVC.WalletTransactionsVC.kindTitle".localized
            let kinds = model.to.map { $0.kind }
            var kindsString = ""
            idx = 1
            for kind in kinds {
                let isLast: Bool = idx == kinds.count
                let separator = isLast ? "" :  ", "
                kindsString += kind.localizationKey.localized + separator
                idx += 1
            }
            cell.kindLabel.text = kindsString
            cell.statusTitle.text = "Me.WalletVC.WalletTransactionsVC.statusTitle".localized
            cell.statusLabel.text = model.serverTxState.localizationKey.localized
        }
    }
}
