//
//  MyProxiesVC.swift
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

class MyProxiesVC: UIViewController {
    var dataSource: MyProxiesDataSource = MyProxiesDataSource(teamID: service.session?.currentTeam?.teamID ?? 0)
    
    @IBOutlet var collectionView: UICollectionView!
    weak var emptyVC: EmptyVC?
    
    var isFirstLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.show(.progress, onView: view)
        setupCollectionView()
        dataSource.onUpdate = { [weak self] in
            HUD.hide()
            self?.collectionView.reloadData()
            self?.showEmptyIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard isFirstLoading == false else {
            dataSource.loadData()
            isFirstLoading = false
            return
        }
        
        dataSource.updateSilently()
    }
    
    func showEmptyIfNeeded() {
        if dataSource.isEmpty {
            if emptyVC == nil {
                let frame = CGRect(x: self.collectionView.frame.origin.x, y: self.collectionView.frame.origin.y,
                                   width: self.collectionView.frame.width,
                                   height: self.collectionView.frame.height)
                emptyVC = EmptyVC.show(in: self, inView: self.collectionView, frame: frame, animated: false)
                emptyVC?.setImage(image: #imageLiteral(resourceName: "iconVote"))
                emptyVC?.setText(title: "Proxy.Empty.title".localized, subtitle: "Proxy.Empty.details".localized)
            }
        } else {
            emptyVC?.remove()
            emptyVC = nil
        }
    }
    
    func setupCollectionView() {
        collectionView.register(ProxyCell.nib, forCellWithReuseIdentifier: ProxyCell.cellID)
        //        collectionView.register(NeedHelpView.nib,
        //                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
        //                                withReuseIdentifier: NeedHelpView.cellID)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(handleGesture(gesture:)))
        longPressGesture.minimumPressDuration = 0.1
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        //        let shortPressGesture = UITapGestureRecognizer(target: self,
        //                                                            action: #selector(handleGesture(gesture:)))
        //        self.collectionView.addGestureRecognizer(shortPressGesture)
    }
    
    @objc
    func handleGesture(gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            let point = gesture.location(in: collectionView)
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: point) else {
                break
            }

            if let cell = collectionView.cellForItem(at: selectedIndexPath) {
            offsetForDraggedCell = offsetOfTouchFrom(recognizer: gesture, inCell: cell)
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            var location = gesture.location(in: collectionView)
            location.x += offsetForDraggedCell.x
            location.y += offsetForDraggedCell.y
            collectionView.updateInteractiveMovementTargetPosition(location)
        case UIGestureRecognizerState.ended:
            // without performing batch update the dragged cell blinks when dropped
           // collectionView.performBatchUpdates({
                self.collectionView.endInteractiveMovement()
           // }, completion: nil)
        default:
            collectionView.cancelInteractiveMovement()
        }
    }

    private var offsetForDraggedCell: CGPoint = .zero

    private func offsetOfTouchFrom(recognizer: UIGestureRecognizer, inCell cell: UICollectionViewCell) -> CGPoint {
        let locationOfTouchInCell = recognizer.location(in: cell)
        let cellCenterX = cell.frame.width / 2
        let cellCenterY = cell.frame.height / 2
        let cellCenter = CGPoint(x: cellCenterX, y: cellCenterY)
        var offset = CGPoint.zero
        offset.y = cellCenter.y - locationOfTouchInCell.y
        offset.x = cellCenter.x - locationOfTouchInCell.x
        return offset
    }
}

extension MyProxiesVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Proxy.MyProxiesVC.indicatorTitle".localized)
    }
}

// MARK: UICollectionViewDataSource
extension MyProxiesVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ProxyCell.cellID, for: indexPath)
    }
    
    //    func collectionView(_ collectionView: UICollectionView,
    //                        viewForSupplementaryElementOfKind kind: String,
    //                        at indexPath: IndexPath) -> UICollectionReusableView {
    //        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
    //                                                                   withReuseIdentifier: NeedHelpView.cellID,
    //                                                                   for: indexPath)
    //        return view
    //    }
    
}

// MARK: UICollectionViewDelegate
extension MyProxiesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        MyProxiesCellBuilder.populate(cell: cell, with: dataSource[indexPath])
        if let cell = cell as? ProxyCell {
            cell.numberLabel.text = String(indexPath.row + 1)
            
            cell.panGesture.removeTarget(nil, action: nil)
            cell.panGesture.addTarget(self, action: #selector(handleGesture(gesture:)))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        //        if let cell = view as? NeedHelpView {
        //            cell.label.text = "Proxy.MyProxiesVC.infoButton".localized
        //        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.items[indexPath.row]
        service.router.presentMemberProfile(teammateID: item.userID, teamID: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        dataSource.move(from: sourceIndexPath, to: destinationIndexPath)

        let idxs = self.collectionView.indexPathsForVisibleItems
        for idx in idxs {
            guard let cell = collectionView.cellForItem(at: idx) as? ProxyCell else { continue }

            cell.numberLabel.text = String(idx.row + 1)
        }
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension MyProxiesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 16 * 2, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 16)
        //return CGSize(width: collectionView.bounds.width, height: 60)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 16)
    }
}
