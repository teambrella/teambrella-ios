//
//  WalletTransactionsCellBuilder.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 01.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
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
                let separator = (idx != amounts.count) ? ", " : ""
                amountString += String(describing: amount) + separator
                idx += 1
            }
            cell.amountLabel.text = amountString + " " + session.coinName
            
            cell.kindTitle.text = "Me.WalletVC.WalletTransactionsVC.kindTitle".localized
            let kinds = model.to.map { $0.kind }
            var kindsString = ""
            idx = 1
            for kind in kinds {
                let separator = (idx != kinds.count) ? ", " : ""
                kindsString += kind.localizationKey.localized + separator
                idx += 1
            }
            cell.kindLabel.text = kindsString
            cell.statusTitle.text = "Me.WalletVC.WalletTransactionsVC.statusTitle".localized
            cell.statusLabel.text = model.serverTxState.localizationKey.localized
        }
    }
}
