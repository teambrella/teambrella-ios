//
//  ClaimVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ClaimVC: UIViewController, Routable {
    
    static var storyboardName = "Claims"
    
    var claim: ClaimLike?
    let dataSource = ClaimDataSource()
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let claim = claim else { return }
        
        setupCells()
        dataSource.onUpdate = { [weak self] in
            self?.collectionView.reloadData()
        }
        dataSource.loadData(claimID: claim.id)
    }
    
    private func setupCells() {
        collectionView.register(ImageGalleryCell.nib, forCellWithReuseIdentifier: ImageGalleryCell.cellID)
        collectionView.register(ClaimVoteCell.nib, forCellWithReuseIdentifier: ClaimVoteCell.cellID)
        collectionView.register(ClaimDetailsCell.nib, forCellWithReuseIdentifier: ClaimDetailsCell.cellID)
        collectionView.register(ClaimOptionsCell.nib, forCellWithReuseIdentifier: ClaimOptionsCell.cellID)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: UICollectionViewDataSource
extension ClaimVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.rows(for: section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: dataSource.cellID(for: indexPath),
                                                  for: indexPath)
    }
    
    //    func collectionView(_ collectionView: UICollectionView,
    //                        viewForSupplementaryElementOfKind kind: String,
    //                        at indexPath: IndexPath) -> UICollectionReusableView {
    //
    //        return view
    //    }
    
}

// MARK: UICollectionViewDelegate
extension ClaimVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let claim = dataSource.claim else { return }
        
        ClaimCellBuilder.populate(cell: cell, with: claim)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension ClaimVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let offset: CGFloat = 16
        switch indexPath.row {
        case 0: return CGSize(width: collectionView.bounds.width, height: 111 + 184)
        case 1: return CGSize(width: collectionView.bounds.width - offset * 2, height: 332)
        case 2: return CGSize(width: collectionView.bounds.width - offset * 2, height: 293)
        case 3: return CGSize(width: collectionView.bounds.width, height: 168)
        default: break
        }
        return CGSize(width: collectionView.bounds.width, height: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 1)
    }
}
