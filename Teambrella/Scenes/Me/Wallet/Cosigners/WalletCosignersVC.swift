//
//  WalletCosignersVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 13.09.17.
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

import UIKit

class WalletCosignersVC: UIViewController, Routable {
    
    static let storyboardName = "Me"
    
    let dataSource: WalletCosignersDataSource = WalletCosignersDataSource()
    fileprivate var previousScrollOffset: CGFloat = 0
    var cosigners: [CosignerEntity]?
    var isFirstLoading = true
    weak var emptyVC: EmptyVC?
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        self.addGradientNavBar()
        WalletCosignersCellBuilder.registerCells(in: collectionView)
        
        title = "Me.WalletVC.WalletCosignersVC.title".localized
        
        dataSource.onUpdate = { [weak self] in
            self?.collectionView.reloadData()
            self?.showEmptyIfNeeded()
        }
        dataSource.onError = { [weak self] error in
            guard let error = error as? TeambrellaError else { return }
            
            let controller = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            controller.addAction(cancel)
            self?.present(controller, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirstLoading == false else {
            if let cosigners = cosigners {
                dataSource.loadData(cosigners: cosigners)
            }
            isFirstLoading = false
            return
        }
        
        dataSource.updateSilently()
    }
    
    func showEmptyIfNeeded() {
        if dataSource.isEmpty {
            if emptyVC == nil {
                let frame = CGRect(x: self.collectionView.frame.origin.x, y: self.collectionView.frame.origin.y + 44,
                                   width: self.collectionView.frame.width,
                                   height: self.collectionView.frame.height - 44)
                emptyVC = EmptyVC.show(in: self, inView: self.view, frame: frame, animated: false)
                emptyVC?.setImage(image: #imageLiteral(resourceName: "iconTeam"))
                emptyVC?.setText(title: "Me.Wallet.Cosigners.Empty.title".localized,
                                 subtitle: "Me.Wallet.Cosigners.Empty.details".localized)
            }
        } else {
            emptyVC?.remove()
            emptyVC = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK: UICollectionViewDataSource
extension WalletCosignersVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell!
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WalletCosignerCell", for: indexPath)
        return cell
    }
    
}

// MARK: UICollectionViewDelegate
extension WalletCosignersVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let cosigner = dataSource[indexPath]
        WalletCosignersCellBuilder.populate(cell: cell, with: cosigner)
        let maxRow = dataSource.count
        if let cell = cell as? WalletCosignerCell {
            cell.separator.isHidden = indexPath.row == maxRow - 1
            ViewDecorator.decorateCollectionView(cell: cell,
                                                 isFirst: indexPath.row == 0,
                                                 isLast: indexPath.row == maxRow - 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cosigner = dataSource[indexPath]
        service.router.presentMemberProfile(teammateID: cosigner.userId)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension WalletCosignersVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 60)
    }
}

// MARK: UIScrollViewDelegate
extension WalletCosignersVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        previousScrollOffset = currentOffset
    }
}
