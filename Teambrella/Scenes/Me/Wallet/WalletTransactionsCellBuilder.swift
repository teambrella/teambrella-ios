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
            cell.createdTitle.text = "Created:" ///
            cell.createdLabel.text = String(describing: model.dateCreated)
            let names = model.to.map { $0.name }
            var namesString = ""
            var idx = 1
            for name in names {
                let separator = (idx != names.count) ? ", " : ""
                namesString += String(describing: name) + separator
                idx += 1
            }
            cell.nameLabel.text = namesString
            cell.amountTitle.text = "Amount:"
            guard let session = service.session else { return }
            
            let amounts = model.to.map { $0.amount * 1000 }
            cell.amountLabel.text = String(describing: amounts) + " " + session.coinName
            cell.kindTitle.text = "Kind:"
            let kinds = model.to.map { $0.kind }
            var kindsString = ""
            idx = 1
            for kind in kinds {
                let separator = (idx != kinds.count) ? ", " : ""
                kindsString += String(describing: kind) + separator
                idx += 1
            }
            cell.kindLabel.text = kindsString
            cell.statusTitle.text = "Status:"
            cell.statusLabel.text = String(describing: model.serverTxState)
        }
    }
}
