//
//  FeedVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import PKHUD
import UIKit
import XLPagerTabStrip

class FeedVC: UIViewController, IndicatorInfoProvider {
    struct Constant {
        static let cellHeight: CGFloat   = 119
        static let headerHeight: CGFloat = 70
    }

    var dataSource: FeedDataSource = FeedDataSource(teamID: service.session.currentTeam?.teamID ?? 0)
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        HUD.show(.progress, onView: view)
        dataSource.loadData()
        dataSource.onLoad = { [weak self] in
            HUD.hide()
            self?.collectionView.reloadData()
        }
    }
    
    func setupCollectionView() {
        collectionView.register(TeamFeedCell.nib, forCellWithReuseIdentifier: TeamFeedCell.cellID)
        collectionView.register(HeaderWithButton.nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: HeaderWithButton.cellID)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Team.FeedVC.indicatorTitle".localized)
    }

}

// MARK: UICollectionViewDataSource
extension FeedVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: TeamFeedCell.cellID, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                               withReuseIdentifier: HeaderWithButton.cellID,
                                                               for: indexPath)
    }
    
}

// MARK: UICollectionViewDelegate
extension FeedVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        FeedCellBuilder.populate(cell: cell, with: dataSource[indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if let view = view as? HeaderWithButton {
            view.button.setTitle("Start Discussion", for: .normal)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedEntity = dataSource[indexPath]
        let context = ChatContext.feed(feedEntity)
        service.router.presentChat(context: context)
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension FeedVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: Constant.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: Constant.headerHeight)
    }
}
