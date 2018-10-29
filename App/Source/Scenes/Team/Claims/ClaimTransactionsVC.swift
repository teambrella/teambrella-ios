//
//  ClaimTransactionsVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 29.08.17.
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

class ClaimTransactionsVC: UIViewController, Routable {
    
    static let storyboardName = "Claims"
    
    var teamID: Int?
    var claimID: Int?
    var userID: String = ""
    var dataSource: ClaimTransactionsDataSource!
    fileprivate var previousScrollOffset: CGFloat = 0
    weak var emptyVC: EmptyVC?
    
    @IBOutlet var collectionView: UICollectionView!
    
    var router: MainRouter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientNavBar()
        HUD.show(.progress, onView: view)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        title = "Team.Claims.ClaimTransactionsVC.title".localized
        
        collectionView.register(WalletTransactionCell.nib, forCellWithReuseIdentifier: WalletTransactionCell.cellID)
        collectionView.register(InfoHeader.nib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: InfoHeader.cellID)
        
        guard let teamID = teamID, let claimID = claimID else { return }
        
        dataSource = ClaimTransactionsDataSource(teamID: teamID, claimID: claimID)
        dataSource.onUpdate = { [weak self] in
            HUD.hide()
            self?.collectionView.reloadData()
            self?.showEmptyIfNeeded()
        }
        dataSource.onError = { error in
            HUD.hide()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.loadData()
    }
    
    func showEmptyIfNeeded() {
        if dataSource.isEmpty {
            if emptyVC == nil {
                let frame = CGRect(x: self.collectionView.frame.origin.x, y: self.collectionView.frame.origin.y + 44,
                                   width: self.collectionView.frame.width,
                                   height: self.collectionView.frame.height - 44)
                emptyVC = EmptyVC.show(in: self, inView: self.view, frame: frame, animated: false)
                emptyVC?.setImage(image: #imageLiteral(resourceName: "iconVote"))
                emptyVC?.setText(title: "Team.Claim.Transactions.Empty.title".localized,
                                 subtitle: "Team.Claim.Transactions.Empty.details".localized)
            }
        } else {
            emptyVC?.remove()
            emptyVC = nil
        }
    }
    
}

// MARK: UICollectionViewDataSource
extension ClaimTransactionsVC: UICollectionViewDataSource {
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
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                               withReuseIdentifier: InfoHeader.cellID,
                                                               for: indexPath)
    }
}

// MARK: UICollectionViewDelegate
extension ClaimTransactionsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        ClaimTransactionsCellBuilder.populate(cell: cell,
                                              indexPath: indexPath,
                                              with: dataSource[indexPath],
                                              userID: userID,
                                              cellsCount: dataSource.count)
        
        if indexPath.row == (dataSource.count - dataSource.limit / 2) {
            dataSource.loadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        // swiftlint:disable:next empty_count
        if dataSource.count > 0 {
            guard let view = view as? InfoHeader else { return }
            
            view.leadingLabel.text = "Team.Claim.Transactions.from".localized
            view.trailingLabel.text = "General.mETH".localized
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataSource[indexPath]
        if let userID = model.userID {
            router.presentMemberProfile(teammateID: userID, teamID: nil)
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ClaimTransactionsVC: UICollectionViewDelegateFlowLayout {
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
extension ClaimTransactionsVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        previousScrollOffset = currentOffset
    }
}
