//
//  MembersVC.swift
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

import MessageUI
import PKHUD
import UIKit
import XLPagerTabStrip

final class MembersVC: UIViewController, IndicatorInfoProvider {
    struct Constant {
        static let searchViewOffset: CGFloat = -60 // constant offset to reveal button and hide seafchField
    }
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var inviteFriendButton: BorderedButton!
    
    let dataSource = MembersDatasource(orderByRisk: false)
    var searchController: UISearchController!
    fileprivate var previousScrollOffset: CGFloat = 0
    fileprivate var searchbarIsShown = true
   
    var isFirstLoading = true

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(InfoHeader.nib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: InfoHeader.cellID)
        configureSearchController()
        HUD.show(.progress, onView: view)
        dataSource.onUpdate = { [weak self] in
            HUD.hide()
            self?.collectionView.reloadData()
        }
        
        dataSource.onError = { [weak self] error in
            HUD.hide()
            guard let error = error as? TeambrellaError else {
                log(error)
                return
            }
            
            let controller = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            controller.addAction(cancel)
            self?.present(controller, animated: true, completion: nil)
        }
        
        dataSource.loadData()
        ViewDecorator.shadow(for: searchView, opacity: 0.05, radius: 4, offset: CGSize.init(width: 0, height: 4))
        title = "Team.team".localized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isFirstLoading == false else {
            isFirstLoading = false
            return
        }
        
        dataSource.updateSilently()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Team.MembersVC.indicatorTitle".localized)
    }
    
    private func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Team.MembersVC.searchHere".localized
        searchBar.placeholder = "Team.MembersVC.searchHere".localized
            
        searchController.searchBar.delegate = self
        //searchController.searchBar.sizeToFit()
        
        searchBar.backgroundImage = UIImage()
        inviteFriendButton.setTitle("Team.MembersVC.inviteAFriend".localized, for: .normal)
        
    }
    
    fileprivate func showSearchBar(show: Bool, animated: Bool) {
        guard show != searchbarIsShown else { return }
        
        searchViewTopConstraint.constant = show ? Constant.searchViewOffset : -searchView.frame.height
        //collectionView.contentInset.top = show ? searchView.frame.height : 0
        searchbarIsShown = show
        if !show {
            view.endEditing(true)
        }
        if animated {
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.setNeedsLayout()
        }
    }
    
    @IBAction func tapInviteFriendButton(_ sender: UIButton) {
        ShareController().shareInvitation(in: self)
    }
    
    @IBAction func tapSort(_ sender: UIButton) {
        service.router.showFilter(in: self, delegate: self, currentSort: dataSource.sortType)
    }
    
}

// MARK: UICollectionViewDataSource
extension MembersVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.itemsInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell!
        switch dataSource.type(indexPath: indexPath) {
        case .new:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CandidateCell",
                                                      for: indexPath)
            if cell is TeammateCandidateCell {
                
            }
        case .teammate:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TeammateCell",
                                                      for: indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                    withReuseIdentifier: InfoHeader.cellID,
                                                                    for: indexPath)
    }
    
}

// MARK: UICollectionViewDelegate
extension MembersVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? TeammateCandidateCell {
            cell.avatarView.image = #imageLiteral(resourceName: "imagePlaceholder")
        } else if let cell = cell as? TeammateCell {
            cell.avatarView.image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        let teammate = dataSource[indexPath]
        MembersCellBuilder.populate(cell: cell, with: teammate)
        let maxRow = dataSource.itemsInSection(section: indexPath.section)
        if let cell = cell as? TeammateCandidateCell {
            cell.cellSeparator.isHidden = indexPath.row == maxRow - 1
            ViewDecorator.decorateCollectionView(cell: cell,
                                                 isFirst: indexPath.row == 0,
                                                 isLast: indexPath.row == maxRow - 1)
        }
        if let cell = cell as? TeammateCell {
            cell.cellSeparator.isHidden = indexPath.row == maxRow - 1
            ViewDecorator.decorateCollectionView(cell: cell,
                                                 isFirst: indexPath.row == 0,
                                                 isLast: indexPath.row == maxRow - 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if let view = view as? InfoHeader {
            view.leadingLabel.text = dataSource.headerTitle(indexPath: indexPath)
            view.trailingLabel.text = dataSource.headerSubtitle(indexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        service.router.presentMemberProfile(teammateID: dataSource[indexPath].userID)
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension MembersVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 56)
    }
}

// MARK: UISearchResultsUpdating
extension MembersVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

// MARK: UISearchBarDelegate
extension MembersVC: UISearchBarDelegate {
    
}

// MARK: UIScrollViewDelegate
extension MembersVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let velocity = currentOffset - previousScrollOffset
        previousScrollOffset = currentOffset
        
        if velocity > 10 {
            showSearchBar(show: false, animated: true)
        }
        if velocity < -10 {
            showSearchBar(show: true, animated: true)
        }
    }
}

// MARK: SortControllerDelegate
extension MembersVC: SortControllerDelegate {
    func sort(controller: SortVC, didSelect type: SortVC.SortType) {
        dataSource.sort(type: type)
    }
}

// MARK: UIViewControllerPreviewingDelegate
extension MembersVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           commit viewControllerToCommit: UIViewController) {
        service.router.push(vc: viewControllerToCommit, animated: true)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           viewControllerForLocation location: CGPoint) -> UIViewController? {
        let updatedLocation = view.convert(location, to: collectionView)
        guard let indexPath = collectionView?.indexPathForItem(at: updatedLocation) else { return nil }
        guard let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
        
        let teammate = dataSource[indexPath]
        guard let vc = service.router.getControllerMemberProfile(teammateID: teammate.userID, teamID: nil) else {
            return nil
        }
        
        vc.preferredContentSize = CGSize(width: view.bounds.width * 0.8, height: view.bounds.height * 0.9)
        previewingContext.sourceRect = collectionView.convert(cell.frame, to: view)
        vc.isPeeking = true
        return vc
    }
}
