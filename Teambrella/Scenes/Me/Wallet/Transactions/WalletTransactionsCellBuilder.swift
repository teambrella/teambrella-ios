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
    static func populate(cell: UICollectionViewCell,
                         indexPath: IndexPath,
                         with model: WalletTransactionsCellModel,
                         cellsCount: Int) {
        if let cell = cell as? WalletTransactionCell {
            cell.setup(with: model)

            cell.separator.isHidden = indexPath.row == cellsCount - 1
            ViewDecorator.decorateCollectionView(cell: cell,
                                                 isFirst: indexPath.row == 0,
                                                 isLast: indexPath.row == cellsCount - 1)
        }
    }
}
