//
//  ClaimTransactionsCellBuilder.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 29.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct ClaimTransactionsCellBuilder {
    static func populate(cell: UICollectionViewCell, with model: ClaimTransactionsCellModel) {
        if let cell = cell as? ClaimTransactionCell {
            cell.avatar.showAvatar(string: model.avatarString)
            cell.nameLabel.text = model.name
            cell.amountCrypto.text = "Team.Claims.ClaimTransactionsVC.amountCrypto".localized
            guard let session = service.session else { return }
            
            cell.cryptoAmountLabel.text = String(model.amountCrypto * 1000) + " " + session.coinName
            cell.amountFiat.text = "Team.Claims.ClaimTransactionsVC.amountFiat".localized
            cell.fiatAmountLabel.text = String(model.amountFiat)
            cell.status.text = "Team.Claims.ClaimTransactionsVC.status".localized
            cell.statusLabel.text = String(model.status)
        }
    }
}
