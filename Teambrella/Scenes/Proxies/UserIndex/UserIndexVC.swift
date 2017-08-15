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

import UIKit
import XLPagerTabStrip

class UserIndexVC: UIViewController {
    struct Constant {
        static let containerHeightShrinked: CGFloat    = 65
        static let containerHeightExpanded: CGFloat    = 214
        static let avatarSizeShrinked: CGFloat         = 40
        static let avatarSizeExpanded: CGFloat         = 56
        static let userIndexCellHeight: CGFloat        = 75
        static let headerHeight: CGFloat               = 40
        static let scrollingVelocityThreshold: CGFloat = 10
    }
    
    var dataSource: UserIndexDataSource = UserIndexDataSource()
    
    @IBOutlet var topContainer: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var avatarView: RoundBadgedView!
    
    @IBOutlet var topContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var avatarWidthConstant: NSLayoutConstraint!
    
    var isTopContainerShrinked: Bool = false
    fileprivate var previousScrollOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        shrinkTopContainer(false)
    }
    
    private func setupCollectionView() {
        collectionView.register(UserIndexCell.nib, forCellWithReuseIdentifier: UserIndexCell.cellID)
        collectionView.register(InfoHeader.nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: InfoHeader.cellID)
    }
    
    fileprivate func shrinkTopContainer(_ shrink: Bool) {
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
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
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
        let currentOffset = scrollView.contentOffset.y
        let velocity = currentOffset - previousScrollOffset
        previousScrollOffset = currentOffset
        if velocity > Constant.scrollingVelocityThreshold {
            shrinkTopContainer(true)
        }
        if velocity < -Constant.scrollingVelocityThreshold {
            shrinkTopContainer(false)
        }
    }
}
