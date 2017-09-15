//
//  WalletCosignersVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 13.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import PKHUD
import UIKit

class WalletCosignersVC: UIViewController, Routable {
    @IBOutlet var collectionView: UICollectionView!
    
    let dataSource: WalletCosignersDataSource = WalletCosignersDataSource()
    fileprivate var previousScrollOffset: CGFloat = 0
    var cosigners: [CosignerEntity]!
    
    var isFirstLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.onUpdate = { [weak self] in
            HUD.hide()
            self?.collectionView.reloadData()
        }
        
        dataSource.onError = { [weak self] error in
            HUD.hide()
            guard let error = error as? TeambrellaError else { return }
            
            let controller = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            controller.addAction(cancel)
            self?.present(controller, animated: true, completion: nil)
        }
        
        HUD.show(.progress, onView: view)
        dataSource.loadData()
        title = "Me.Wallet.WalletCosignersVC.title".localized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isFirstLoading == false else {
            isFirstLoading = false
            return
        }
        
        dataSource.updateSilently()
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
        let teammate = dataSource[indexPath]
        WalletCosignersCellBuilder.populate(cell: cell, with: teammate)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.items[indexPath.row]
        service.router.presentMemberProfile(teammateID: item.userId)
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
