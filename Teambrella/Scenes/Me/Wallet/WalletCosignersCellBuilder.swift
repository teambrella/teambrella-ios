//
//  WalletCosignersCellBuilder.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 13.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

struct WalletCosignersCellBuilder {
    
    static func registerCells(in collectionView: UICollectionView) {
        collectionView.register(WalletCosignerCell.nib, forCellWithReuseIdentifier: WalletCosignerCell.cellID)
    }
    
    static func populate(cell: UICollectionViewCell, with model: CosignerEntity) {
        if let cell = cell as? WalletCosignerCell {
            cell.avatar.showAvatar(string: model.avatar)
            cell.nameLabel.text = model.name
        }
    }
    
}
