//
//  UserIndexCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import Kingfisher

struct UserIndexCellBuilder {
    static func populate(cell: UICollectionViewCell, with model: UserIndexCellModel) {
        if let cell = cell as? UserIndexCell {
            cell.avatarView.kf.setImage(with: URL(string: model.avatarString))
            cell.nameLabel.text = model.name
            cell.detailsLabel.text = model.city
            cell.amountLabel.text = String(format: "%.2d", model.amount)
        }
    }
    
}
