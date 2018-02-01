//
//  WalletTransactionsVC.swift
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

import PKHUD
import UIKit

class WalletTransactionsVC: UIViewController, Routable {
    
    static let storyboardName = "Me"
    
    var teamID: Int?
    
    var balance: MEth?
    var reserved: Ether?
    
    var dataSource: WalletTransactionsDataSource!
    fileprivate var previousScrollOffset: CGFloat = 0
    weak var emptyVC: EmptyVC?
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientNavBar()
        HUD.show(.progress, onView: view)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        title = "Me.WalletVC.WalletTransactionsVC.title".localized
        collectionView.register(WalletTransactionCell.nib, forCellWithReuseIdentifier: WalletTransactionCell.cellID)
        collectionView.register(InfoHeader.nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: InfoHeader.cellID)
        guard let teamID = teamID else { return }
        
        dataSource = WalletTransactionsDataSource(teamID: teamID)
        dataSource.onUpdate = { [weak self] in
            HUD.hide()
            self?.collectionView.reloadData()
            self?.showEmptyIfNeeded()
        }
        dataSource.onError = { error in
            HUD.hide()
        }
        dataSource.loadData()
    }
    
    func showEmptyIfNeeded() {
        if dataSource.isEmpty && emptyVC == nil {
            emptyVC = EmptyVC.show(in: self)
            emptyVC?.setImage(image: #imageLiteral(resourceName: "iconVote"))
            emptyVC?.setText(title: "Me.Wallet.Transactions.Empty.title".localized,
                             subtitle: "Me.Wallet.Transactions.Empty.details".localized)
        } else {
            emptyVC?.remove()
        }
    }
}

// MARK: UICollectionViewDataSource
extension WalletTransactionsVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: WalletTransactionCell.cellID, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                               withReuseIdentifier: InfoHeader.cellID,
                                                               for: indexPath)
    }
}

// MARK: UICollectionViewDelegate
extension WalletTransactionsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        WalletTransactionsCellBuilder.populate(cell: cell,
                                               indexPath: indexPath,
                                               with: dataSource[indexPath],
                                               cellsCount: dataSource.count)
        
        if indexPath.row == (dataSource.count - dataSource.limit / 2) {
            dataSource.loadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if dataSource.count > 0 {
            guard let view = view as? InfoHeader else { return }
            
            view.leadingLabel.text = "Me.Wallet.Transactions.to".localized
            view.trailingLabel.text = "General.mETH".localized
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataSource[indexPath]
        if let claimID = model.claimID {
            service.router.presentClaim(claimID: claimID)
        } else if let balance = balance, let reserved = reserved {
            service.router.presentWithdraw(balance: balance, reserved: reserved)
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension WalletTransactionsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}

// MARK: UIScrollViewDelegate
extension WalletTransactionsVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        previousScrollOffset = currentOffset
    }
}
