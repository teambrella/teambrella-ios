//
//  WalletCellBulider.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import Kingfisher

struct WalletCellBuilder {
    static func registerCells(in collectionView: UICollectionView) {
        collectionView.register(WalletHeaderCell.nib, forCellWithReuseIdentifier: WalletHeaderCell.cellID)
        collectionView.register(WalletButtonsCell.nib, forCellWithReuseIdentifier: WalletButtonsCell.cellID)
        collectionView.register(WalletFundingCell.nib, forCellWithReuseIdentifier: WalletFundingCell.cellID)
    }
    
    static func dequeueCell(in collectionView: UICollectionView,
                            indexPath: IndexPath,
                            for model: WalletCellModel) -> UICollectionViewCell {
        if model is WalletHeaderCellModel {
           return collectionView.dequeueReusableCell(withReuseIdentifier: WalletHeaderCell.cellID, for: indexPath)
        } else if model is WalletButtonsCellModel {
            return collectionView.dequeueReusableCell(withReuseIdentifier: WalletButtonsCell.cellID, for: indexPath)
        } else if model is WalletFundingCellModel {
           return collectionView.dequeueReusableCell(withReuseIdentifier: WalletFundingCell.cellID, for: indexPath)
        } else {
            fatalError("Unknown model type for Wallet Cell")
        }
    }
    
    static func populate(cell: UICollectionViewCell, with model: WalletCellModel) {
//        if let cell = cell as? WalletHeaderCell {
//            cell.amount.text = String.formattedNumber(model.amount)
//            //cell.currencyLabel.text = String.formattedNumber(model.)
//            cell.numberBar.left?.titleLabel.text = "Me.WalletVC.leftBrick.title".localized
//            cell.numberBar.left?.amountLabel.text = String.formattedNumber(model.reserved)
//            cell.numberBar.right?.titleLabel.text = "Me.WalletVC.rightBrick.title".localized
//            cell.numberBar.right?.amountLabel.text = String.formattedNumber(model.available)
//            cell.button.setTitle("Me.WalletVC.withdrawButton".localized, for: .normal)
//        }
//        if let cell = cell as? WalletFundingCell {
//            cell.headerLabel.text = "Me.WalletVC.fundingCell.title".localized
//            cell.upperNumberView.titleLabel.text = "Me.WalletVC.upperBrick.title".localized
//            cell.upperNumberView.amountLabel.text = String.formattedNumber(model.maxCoverageFunding)
//            cell.upperCurrencyLabel.text = String.formattedNumber(model.maxCoverageFunding)
//            cell.lowerNumberView.titleLabel.text = "Me.WalletVC.lowerBrick.title".localized
//            cell.lowerCurrencyLabel.text = String.formattedNumber(model.uninterruptedCoverageFunding)
//            cell.fundWalletButton.setTitle("Me.WalletVC.fundButton".localized, for: .normal)
//        }
//        if let cell = cell as? WalletButtonsCell {
//            cell.topViewLabel.text = "Me.WalletVC.actionsCell.cosigners".localized
//            cell.imagesStack = model.avatars
//            cell.middleViewLabel.text = "Me.WalletVC.actionsCell.transactions".localized
//            cell.bottomViewLabel.text = "Me.WalletVC.actionsCell.withdrawAddress".localized
//        }
    }
    
}
