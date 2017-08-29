//
//  ClaimTransactionsVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 29.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ClaimTransactionsVC: UIViewController, Routable {
    var teamID: Int = 0
    var claimID: Int = 0
    var dataSource: ClaimTransactionsDataSource!
    fileprivate var previousScrollOffset: CGFloat = 0
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(ClaimTransactionCell.nib, forCellWithReuseIdentifier: ClaimTransactionCell.cellID)
        dataSource = ClaimTransactionsDataSource(teamID: teamID, claimID: claimID)

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
        return collectionView.dequeueReusableCell(withReuseIdentifier: ClaimTransactionCell.cellID, for: indexPath)
    }
    
}

// MARK: UICollectionViewDelegate
extension ClaimTransactionsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        ClaimTransactionsCellBuilder.populate(cell: cell, with: dataSource[indexPath])
        if indexPath.row == (dataSource.count - dataSource.limit/2) {
            dataSource.loadData()
        }
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension ClaimTransactionsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height/5 )
    }
}

// MARK: UIScrollViewDelegate
extension ClaimTransactionsVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        previousScrollOffset = currentOffset
    }
}
