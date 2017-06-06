//
//  ClaimsVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import XLPagerTabStrip

/**
 Shows the list of all claims or the list of claims created by a teammate if the teammate is given
 */
class ClaimsVC: UIViewController, IndicatorInfoProvider, Routable {
    static var storyboardName: String = "Claims"
    
    @IBOutlet var collectionView: UICollectionView!
    var dataSource = ClaimsDataSource()
    
    var teammate: TeammateLike?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.teammate = teammate
        dataSource.loadData()
        dataSource.onUpdate = { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Claims")
    }
    
}

// MARK: UICollectionViewDataSource
extension ClaimsVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.cellsIn(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: dataSource.cellIdentifier(for: indexPath),
                                                  for: indexPath)

    }
}

// MARK: UICollectionViewDelegate
extension ClaimsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        ClaimsCellBuilder.populate(cell: cell, with: dataSource[indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let claim = dataSource[indexPath]
        TeamRouter().presentClaim(claim: claim)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ClaimsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGSize!
        switch dataSource.cellType(for: indexPath) {
        case .open: size = CGSize(width: collectionView.bounds.width - 32, height: 156)
        case .voted: size = CGSize(width: collectionView.bounds.width, height: 112)
        case .paid, .fullyPaid: size = CGSize(width: collectionView.bounds.width, height: 79)
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 1)
    }
}
