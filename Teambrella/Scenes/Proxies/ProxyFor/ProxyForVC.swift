//
//  ProxyForVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ProxyForVC: UIViewController {
    var dataSource: ProxyForDataSource = ProxyForDataSource(teamID: service.session.currentTeam?.teamID ?? 0)
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        dataSource.onUpdate = { [weak self] in
            self?.collectionView.reloadData()
        }
        dataSource.loadData()
    }
    
    private func setupCollectionView() {
        collectionView.register(ProxyForCell.nib, forCellWithReuseIdentifier: ProxyForCell.cellID)
        collectionView.register(ProxyForHeader.nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: ProxyForHeader.cellID)
    }
    
}

extension ProxyForVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Proxy.ProxyForVC.indicatorTitle".localized)
    }
}

// MARK: UICollectionViewDataSource
extension ProxyForVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ProxyForCell.cellID, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                               withReuseIdentifier: ProxyForHeader.cellID,
                                                               for: indexPath)
    }
    
}

// MARK: UICollectionViewDelegate
extension ProxyForVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        ProxyForCellBuilder.populate(cell: cell, with: dataSource[indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if let cell = view as? ProxyForHeader {
            cell.headerLabel.text = "TOTAL COMMISSION" //
            cell.amountLabel.text = "$" + String(dataSource.commission)
            cell.detailsLabel.text = "WHO YOU'RE A PROXY FOR" //
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension ProxyForVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 126)
    }
}
