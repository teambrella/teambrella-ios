//
//  FeedVC.swift
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

class FeedVC: UIViewController, IndicatorInfoProvider {
    struct Constant {
        static let cellHeight: CGFloat   = 119
        static let headerHeight: CGFloat = 72
    }

    var dataSource: FeedDataSource = FeedDataSource(teamID: service.session?.currentTeam?.teamID ?? 0)
    
    @IBOutlet var collectionView: UICollectionView!
    
    var isFirstLoading = true
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isFirstLoading == false else {
            isFirstLoading = false
            return
        }
        
        dataSource.updateSilently()
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

    @objc
    func tapStartDiscussion(sender: UIButton) {
        service.router.presentReport(context: .newChat, delegate: self)
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
            view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            view.separator.isHidden = false
            view.button.setTitle("Team.FeedVC.startDiscussionButton.title".localized, for: .normal)
            view.button.removeTarget(self, action: nil, for: .allEvents)
            view.button.addTarget(self, action: #selector(tapStartDiscussion), for: .touchUpInside)
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

extension FeedVC: ReportDelegate {
    func report(controller: ReportVC, didSendReport data: Any) {
        if let data = data as? ChatModel {
            service.router.navigator?.popViewController(animated: false)
            let context = ChatContext.chat(data)
            service.router.presentChat(context: context)
        }
    }
}
