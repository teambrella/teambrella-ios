//
//  ProxyForVC.swift
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

class ProxyForVC: UIViewController {
    var dataSource: ProxyForDataSource = ProxyForDataSource(teamID: service.session?.currentTeam?.teamID ?? 0)
    weak var emptyVC: EmptyVC?
    
    @IBOutlet var collectionView: UICollectionView!
    
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
        if dataSource.isEmpty && emptyVC == nil {
            let frame = CGRect(x: self.collectionView.frame.origin.x, y: self.collectionView.frame.origin.y,
                               width: self.collectionView.frame.width,
                               height: self.collectionView.frame.height)
            emptyVC = EmptyVC.show(in: self, inView: self.collectionView, frame: frame, animated: false)
            emptyVC?.setImage(image: #imageLiteral(resourceName: "iconVote"))
            emptyVC?.setText(title: "Proxy.Empty.You.title".localized, subtitle: "Proxy.Empty.You.details".localized)
        } else {
            emptyVC?.remove()
            emptyVC = nil
        }
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
        let isLast = indexPath.row == dataSource.count - 1
        if let cell = cell as? ProxyForCell {
            cell.separatorView.isHidden = isLast
        }
        ViewDecorator.decorateCollectionView(cell: cell, isFirst: indexPath.row == 0, isLast: isLast)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if let cell = view as? ProxyForHeader {
            cell.headerLabel.text = "Proxy.ProxyForVC.header".localized
            cell.detailsLabel.text = "Proxy.ProxyForVC.subtitle".localized
            ViewDecorator.shadow(for: cell)
            ViewDecorator.roundedEdges(for: cell.containerView)
            guard let team = service.session?.currentTeam else { return }
            
            cell.amountLabel.text = team.currencySymbol + String(Int(dataSource.commission))
            cell.currencyLabel.text = team.currency
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.items[indexPath.row]
        service.router.presentMemberProfile(teammateID: item.userID)
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
        return dataSource.isEmpty ? .zero : CGSize(width: collectionView.bounds.width, height: 126)
    }
}
