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
            cell.txNumberLabel.text = model.txID
            cell.cryptoAmountLabel.text = String(model.amountCrypto)
            cell.fiatAmountLabel.text = String(model.amountFiat)
            cell.container.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        }
    }

}
