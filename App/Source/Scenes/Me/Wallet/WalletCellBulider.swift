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
        collectionView.register(WalletTxsCell.nib, forCellWithReuseIdentifier: WalletTxsCell.cellID)
    }
    
    static func dequeueCell(in collectionView: UICollectionView,
                            indexPath: IndexPath,
                            for model: WalletCellModel) -> UICollectionViewCell {
        if model is WalletHeaderCellModel {
            return collectionView.dequeueReusableCell(withReuseIdentifier: WalletHeaderCell.cellID, for: indexPath)
        } else if model is WalletButtonsCellModel {
            return collectionView.dequeueReusableCell(withReuseIdentifier: WalletButtonsCell.cellID, for: indexPath)
        } else if model is WalletTxsCellModel {
            return collectionView.dequeueReusableCell(withReuseIdentifier: WalletTxsCell.cellID, for: indexPath)
        } else {
            fatalError("Unknown model type for Wallet Cell")
        }
    }
    
    static func populate(cell: UICollectionViewCell, with model: WalletCellModel, delegate: WalletVC) {
        if let cell = cell as? WalletHeaderCell, let model = model as? WalletHeaderCellModel {
            populateHeader(cell: cell, model: model)
        }
        if let cell = cell as? WalletTxsCell, let model = model as? WalletTxsCellModel {
            populateFunding(cell: cell, model: model)
        }
        if let cell = cell as? WalletButtonsCell, let model = model as? WalletButtonsCellModel {
            populateButtons(cell: cell, model: model, delegate: delegate)
        }
    }
    
    private static func populateHeader(cell: WalletHeaderCell, model: WalletHeaderCellModel) {
        balance = MEth(model.amount)
        cell.amount.text = String.formattedNumber(floor(balance.value))
        
        cell.withdrawButton.setTitle("Me.WalletVC.withdrawButton".localized, for: .normal)
        cell.fundWalletButton.setTitle("Me.WalletVC.fundButton".localized, for: .normal)
        
        cell.currencyLabel.text = service.session?.cryptoCoin.code
        currencyRate = model.currencyRate
        if let team = service.session?.currentTeam {
            cell.auxillaryAmount.text = String.formattedNumber(floor(model.amount.value * currencyRate))
                + " " + team.currency
        }
        
        let isWalletCommentHidden = model.fundWalletComment == ""
        cell.fundWalletLabel.isHidden = isWalletCommentHidden
        cell.walletFundLabelHidden.isActive = isWalletCommentHidden
        cell.walletFundLabelVisible.isActive = !isWalletCommentHidden
        cell.fundWalletLabel.text = model.fundWalletComment
    }
    
    private static func populateFunding(cell: WalletTxsCell, model: WalletTxsCellModel) {
        cell.headerLabel.text = "Me.WalletVC.txsCell.title".localized
        cell.spendingsView.left?.isBadgeVisible = false
        cell.spendingsView.left?.isPercentVisible = false
        cell.spendingsView.left?.isCurrencyVisible = true
        cell.spendingsView.right?.isBadgeVisible = false
        cell.spendingsView.right?.isPercentVisible = false
        cell.spendingsView.right?.isCurrencyVisible = true

        if let team = service.session?.currentTeam {
            cell.spendingsView.left?.currencyLabel.text = team.currency
            cell.spendingsView.right?.currencyLabel.text = team.currency
        }
        
        cell.spendingsView.right?.titleLabel.text = String(format: "Me.WalletVC.txsCell.payoutsForPeriod".localized,
                                                          Formatter.monthName.string(from: Date()).capitalized).uppercased()
        cell.spendingsView.left?.titleLabel.text = String(format: "Me.WalletVC.txsCell.payoutsForYear".localized, Date().year).uppercased()
        cell.spendingsView.right?.amountLabel.text =  String(format: "%.0f", model.amountFiatMonth.value)
        cell.spendingsView.left?.amountLabel.text = String(format: "%.0f", model.amountFiatYear.value)
        cell.spendingsView.left?.showSignIfNeeded()
        cell.spendingsView.right?.showSignIfNeeded()

        cell.allTxsButton.setTitle("Me.WalletVC.allTxsButton".localized, for: .normal)
    }
    
    private static func populateButtons(cell: WalletButtonsCell, model: WalletButtonsCellModel, delegate: WalletVC) {
        let avatars = model.avatarsPreview.compactMap { $0.url }
        let maxAvatarsStackCount = 4
        let otherVotersCount = model.avatars.count - maxAvatarsStackCount + 1
        let label: String?  =  otherVotersCount > 0 ? "+\(otherVotersCount)" : nil
        cell.imagesStack.set(images: avatars, label: label, max: maxAvatarsStackCount)
        cell.cosignersViewLabel.text = "Me.WalletVC.actionsCell.cosigners".localized
        cell.backupViewLabel.text = "Me.WalletVC.actionsCell.backupWallet".localized
        cell.tapCosignersViewRecognizer.removeTarget(delegate, action: nil)
        cell.tapCosignersViewRecognizer.addTarget(delegate, action: #selector(WalletVC.tapCosigners))
        cell.tapBackupViewRecognizer.removeTarget(delegate, action: nil)
        cell.tapBackupViewRecognizer.addTarget(delegate, action: #selector(WalletVC.tapBackupWallet))
    }
    
}
