//
//  UserIndexCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.

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

import Foundation
import Kingfisher

struct UserIndexCellBuilder {
    static func populate(cell: UICollectionViewCell, with model: UserIndexCellModel) {
        if let cell = cell as? UserIndexCell {
            cell.avatarView.showAvatar(string: model.avatarString)
            cell.nameLabel.text = model.name
            cell.detailsLabel.text = model.location.uppercased()
            cell.amountLabel.text = String(format: "%.2f", model.proxyRank)
        }
    }
    
}
