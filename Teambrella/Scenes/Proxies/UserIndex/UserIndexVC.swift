//
//  UserIndexVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.

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

class UserIndexVC: UIViewController {
    struct Constant {
        static let containerHeightShrinked: CGFloat    = 65
        static let containerHeightExpanded: CGFloat    = 214
        static let avatarSizeShrinked: CGFloat         = 40
        static let avatarSizeExpanded: CGFloat         = 56
        static let userIndexCellHeight: CGFloat        = 75
        static let headerHeight: CGFloat               = 50
        static let scrollingVelocityThreshold: CGFloat = 10
    }
    
    var dataSource: UserIndexDataSource = UserIndexDataSource(teamID: service.session?.currentTeam?.teamID ?? 0)
    
    @IBOutlet var topContainer: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var avatarView: RoundBadgedView!
    @IBOutlet var detailsLabel: InfoLabel!
    @IBOutlet var rankLabel: AmountLabel!
    @IBOutlet var sortButton: UIButton!
    @IBOutlet var youLabel: Label!
    
    @IBOutlet var buttonView: UIView!
    
    @IBOutlet var optIntoRatingButton: BorderedButton!
    @IBOutlet var topContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var avatarWidthConstant: NSLayoutConstraint!
    
    @IBAction func tapSort(_ sender: Any) {
        service.router.showFilter(in: self, delegate: self, currentSort: dataSource.sortType)
    }
    
    @IBAction func tapOpt(_ sender: Any) {
        changeOpting()
    }
    
    var isTopContainerShrinked: Bool = false
    fileprivate var previousScrollOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewDecorator.shadow(for: topContainer, opacity: 0.1, radius: 5)
        HUD.show(.progress, onView: view)
        setupCollectionView()
        shrinkTopContainer(true)
        dataSource.loadData()
        dataSource.onUpdate = { [weak self] in
            guard let dataSource = self?.dataSource, let me = dataSource.meModel else { return }
            
            self?.avatarView.showAvatar(string: me.avatarString)
            self?.detailsLabel.text = me.location.uppercased()
            self?.rankLabel.text = String(format: "%.1f", me.proxyRank)
            HUD.hide()
            self?.collectionView.reloadData()
        }
        youLabel.text = "General.you".localized
        detailsLabel.text = ""
    }
    
    private func setupCollectionView() {
        collectionView.register(UserIndexCell.nib, forCellWithReuseIdentifier: UserIndexCell.cellID)
        collectionView.register(InfoHeader.nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: InfoHeader.cellID)
    }
    
    func configureSearchContainer() {
        //        searchController = UISearchController(searchResultsController: nil)
        //        searchController.searchResultsUpdater = self
        //        searchController.dimsBackgroundDuringPresentation = true
        //        searchController.searchBar.placeholder = "Team.MembersVC.searchHere".localized
        //        searchBar.placeholder = "Team.MembersVC.searchHere".localized
        //
        //        searchController.searchBar.delegate = self
        //        searchController.searchBar.sizeToFit()
    }
    
    func changeOpting() {
        dataSource.isInRating = !dataSource.isInRating
        let title = dataSource.isInRating ?
            "Proxy.UserIndexVC.optButton.title.out".localized :
            "Proxy.UserIndexVC.optButton.title.in".localized
        optIntoRatingButton.setTitle(title, for: .normal)
        collectionView.reloadData()
    }
    
    fileprivate func shrinkTopContainer(_ shrink: Bool) {
        view.layoutIfNeeded()
        topContainerHeightConstraint.constant = shrink
            ? Constant.containerHeightShrinked
            : Constant.containerHeightExpanded
        collectionView.contentInset.top = shrink
            ? Constant.containerHeightShrinked
            : Constant.containerHeightExpanded
        avatarWidthConstant.constant = shrink
            ? Constant.avatarSizeShrinked
            : Constant.avatarSizeExpanded
        isTopContainerShrinked = shrink
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.buttonView.alpha = shrink
                ? 0
                : 1
        }
    }
    
}

extension UserIndexVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Proxy.UserIndexVC.indicatorTitle".localized)
    }
}

// MARK: UICollectionViewDataSource
extension UserIndexVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: UserIndexCell.cellID, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                               withReuseIdentifier: InfoHeader.cellID,
                                                               for: indexPath)
    }
    
}

// MARK: UICollectionViewDelegate
extension UserIndexVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        UserIndexCellBuilder.populate(cell: cell, with: dataSource[indexPath])
        let maxRow = dataSource.count
        if let cell = cell as? UserIndexCell {
            cell.numberLabel.text = String(indexPath.row + 1)
            cell.cellSeparator.isHidden = indexPath.row == maxRow - 1
            ViewDecorator.decorateCollectionView(cell: cell,
                                                 isFirst: indexPath.row == 0,
                                                 isLast: indexPath.row == maxRow - 1)
        }
        
        if indexPath.row == (dataSource.count - dataSource.limit / 2) {
            dataSource.loadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if let cell = view as? InfoHeader {
            cell.leadingLabel.text = "Proxy.UserIndexVC.allTeamsRating".localized
            cell.trailingLabel.text = "Proxy.UserIndexVC.proxyRank".localized
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        service.router.presentMemberProfile(teammateID: dataSource[indexPath].userID)
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension UserIndexVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: Constant.userIndexCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: Constant.headerHeight)
    }
}

// MARK: UIScrollViewDelegate
extension UserIndexVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*
        let currentOffset = scrollView.contentOffset.y
        let velocity = currentOffset - previousScrollOffset
        previousScrollOffset = currentOffset
        if velocity > Constant.scrollingVelocityThreshold {
            shrinkTopContainer(true)
        }
        if velocity < -Constant.scrollingVelocityThreshold {
            shrinkTopContainer(false)
        }
 */
    }
}

// MARK: SortControllerDelegate
extension UserIndexVC: SortControllerDelegate {
    func sort(controller: SortVC, didSelect type: SortVC.SortType) {
        dataSource.sortType = type
        dataSource.loadData()
    }
}
