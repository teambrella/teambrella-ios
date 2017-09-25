//
//  ClaimsVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.05.17.

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

import PKHUD
import UIKit
import XLPagerTabStrip

/**
 Shows the list of all claims or the list of claims created by a teammate if the teammate is given
 */
class ClaimsVC: UIViewController, IndicatorInfoProvider, Routable {
    static var storyboardName: String = "Claims"
    
    @IBOutlet var collectionView: UICollectionView!
    var dataSource = ClaimsDataSource()
    
    var teammate: TeammateEntity?
    
    var isFirstLoading = true
    // is pushed to navigation stack instead of being the first controller in XLPagerTabStrip
    var isPresentedInStack = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.show(.progress, onView: view)
        registerCells()
        dataSource.teammate = teammate
        dataSource.loadData()
        dataSource.onUpdate = { [weak self] in
            HUD.hide()
            self?.collectionView.reloadData()
        }
        if isPresentedInStack {
            addGradientNavBar()
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isFirstLoading == false else {
            isFirstLoading = false
            return
        }
        
        dataSource.updateSilently()
    }
    
    func registerCells() {
        collectionView.register(InfoHeader.nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: InfoHeader.cellID)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Team.ClaimsVC.indicatorTitle".localized)
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
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                               withReuseIdentifier: InfoHeader.cellID, for: indexPath)
    }
}

// MARK: UICollectionViewDelegate
extension ClaimsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        ClaimsCellBuilder.populate(cell: cell, with: dataSource[indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if let view = view as? InfoHeader {
            view.leadingLabel.text = dataSource.headerText(for: indexPath)
            view.trailingLabel.text = ""
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let claim = dataSource[indexPath]
        service.router.presentClaim(claim: claim)
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
        return CGSize(width: collectionView.bounds.width, height: dataSource.showHeader(for: section) ? 50 : 0.01)
    }
}
