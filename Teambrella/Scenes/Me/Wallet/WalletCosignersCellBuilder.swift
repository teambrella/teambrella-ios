//
//  WalletCosignersCellBuilder.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 13.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

struct WalletCosignersCellBuilder {
    static func populate(cell: UICollectionViewCell, with model: CosignerEntity) {
        if let cell = cell as? WalletCosignerCell {
            if let url = URL(string: service.server.avatarURLstring(for: model.avatar)) {
                cell.avatar.kf.setImage(with: url)
            }
            cell.nameLabel.text = model.name
        }
    }
    
}
