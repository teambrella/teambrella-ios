//
//  WalletCellBulider.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.

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

struct WalletCellBuilder {
    static var currencyRate: Double = 0.0
    static var balance: MEth = MEth.empty
    
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
    
    static func populate(cell: UICollectionViewCell, with model: WalletCellModel, delegate: WalletVC) {
        if let cell = cell as? WalletHeaderCell, let model = model as? WalletHeaderCellModel {
            populateHeader(cell: cell, model: model)
        }
        if let cell = cell as? WalletFundingCell, let model = model as? WalletFundingCellModel {
            populateFunding(cell: cell, model: model)
        }
        if let cell = cell as? WalletButtonsCell, let model = model as? WalletButtonsCellModel {
            populateButtons(cell: cell, model: model, delegate: delegate)
        }
    }
    
    private static func populateHeader(cell: WalletHeaderCell, model: WalletHeaderCellModel) {
        cell.amount.text = String.formattedNumber(MEth(model.amount).value)
        balance = MEth(model.amount)
        
        cell.button.setTitle("Me.WalletVC.withdrawButton".localized, for: .normal)
        cell.currencyLabel.text = service.session?.cryptoCoin.code
        currencyRate = model.currencyRate
        if let team = service.session?.currentTeam {
            cell.auxillaryAmount.text = String.formattedNumber(model.amount.value * currencyRate) + " " + team.currency
        }
    }
    
    private static func populateFunding(cell: WalletFundingCell, model: WalletFundingCellModel) {
        cell.headerLabel.text = balance.value > 0
            ? "Me.WalletVC.fundingCell.additionalTitle".localized
            : "Me.WalletVC.fundingCell.title".localized
        if let team = service.session?.currentTeam {
            cell.lowerCurrencyLabel.text =
                String.formattedNumber(model.uninterruptedCoverageFunding.value * currencyRate) + " " + team.currency
        }
        cell.lowerNumberView.titleLabel.text = "Me.WalletVC.lowerBrick.title".localized
        cell.lowerNumberView.amountLabel.text = String.formattedNumber(MEth(model.uninterruptedCoverageFunding).value)
        cell.lowerNumberView.isBadgeVisible = false
        cell.fundWalletButton.setTitle("Me.WalletVC.fundButton".localized, for: .normal)
    }
    
    private static func populateButtons(cell: WalletButtonsCell, model: WalletButtonsCellModel, delegate: WalletVC) {
        cell.topViewLabel.text = "Me.WalletVC.actionsCell.cosigners".localized
        cell.imagesStack.setAvatars(images: model.avatarsPreview)
        cell.middleViewLabel.text = "Me.WalletVC.actionsCell.transactions".localized
        cell.bottomViewLabel.text = "Me.WalletVC.actionsCell.withdrawAddress".localized
        cell.quantityLabel.text = String(model.avatars.count)
        cell.tapMiddleViewRecognizer.removeTarget(delegate, action: nil)
        cell.tapMiddleViewRecognizer.addTarget(delegate, action: #selector(WalletVC.tapTransactions))
        cell.tapTopViewRecognizer.removeTarget(delegate, action: nil)
        cell.tapTopViewRecognizer.addTarget(delegate, action: #selector(WalletVC.tapCosigners))
    }
    
}
