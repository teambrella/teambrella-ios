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
    
    static func populate(cell: UICollectionViewCell, with model: ReportCellModel) {
        if let cell = cell as? ReportItemCell, let model = model as? ItemReportCellModel {
            cell.avatarView.showImage(string: model.photo)
            cell.itemLabel.text = model.name
            cell.detailsLabel.text = model.location
            cell.headerLabel.text = model.title
        } else if let cell = cell as? ReportExpensesCell, let model = model as? ExpensesReportCellModel {
            cell.headerLabel.text = model.title
            cell.numberBar.left?.titleLabel.text = model.deductibleTitle
            cell.numberBar.middle?.titleLabel.text = model.coverageTitle
            cell.numberBar.right?.titleLabel.text = model.amountTitle
            
            cell.numberBar.left?.amountLabel.text = model.deductibleString
            cell.numberBar.middle?.amountLabel.text = model.coverageString
            cell.numberBar.right?.amountLabel.text = model.expensesString
        } else if let cell = cell as? ReportDescriptionCell, let model = model as? DescriptionReportCellModel {
            cell.headerLabel.text = model.title
            cell.textView.text = model.text
        } else if let cell = cell as? ReportPhotoGalleryCell, let model = model as? PhotosReportCellModel {
            cell.headerLabel.text = model.title
            cell.button.setTitle(model.buttonTitle, for: .normal)
        } else if let cell = cell as? ReportTextFieldCell, let model = model as?  DateReportCellModel {
            cell.headerLabel.text = model.title
        } else if let cell = cell as? ReportTextFieldCell, let model = model as? WalletReportCellModel {
            cell.headerLabel.text = model.title
        }
    }
    
}
