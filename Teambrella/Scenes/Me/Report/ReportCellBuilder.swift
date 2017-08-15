//
//  ReportCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 26.06.17.

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

struct ReportCellBuilder {
    static func registerCells(in collectionView: UICollectionView) {
        collectionView.register(ReportItemCell.nib, forCellWithReuseIdentifier: ReportItemCell.cellID)
        collectionView.register(ReportExpensesCell.nib, forCellWithReuseIdentifier: ReportExpensesCell.cellID)
        collectionView.register(ReportDescriptionCell.nib, forCellWithReuseIdentifier: ReportDescriptionCell.cellID)
        collectionView.register(ReportPhotoGalleryCell.nib, forCellWithReuseIdentifier: ReportPhotoGalleryCell.cellID)
        collectionView.register(ReportTextFieldCell.nib, forCellWithReuseIdentifier: ReportTextFieldCell.cellID)
    }
    
    static func dequeueCell(in collectionView: UICollectionView,
                            indexPath: IndexPath,
                            type: ReportDataSource.ReportCellType) -> UICollectionViewCell {
        let id: String!
        switch type {
        case .item:
           id = ReportItemCell.cellID
        case .date, .wallet:
            id = ReportTextFieldCell.cellID
        case .expenses:
            id = ReportExpensesCell.cellID
        case .description:
            id = ReportDescriptionCell.cellID
        case .photos:
           id = ReportPhotoGalleryCell.cellID
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath)
    }
    
    static func populate(cell: UICollectionViewCell, with type: ReportDataSource.ReportCellType) {

    }
}
