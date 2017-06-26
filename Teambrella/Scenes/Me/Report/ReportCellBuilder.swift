//
//  ReportCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 26.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
