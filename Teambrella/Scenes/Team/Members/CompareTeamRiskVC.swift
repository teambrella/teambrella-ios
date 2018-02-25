//
//  CompareTeamRiskVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 11.07.17.

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

class CompareTeamRiskVC: UIViewController, Routable {
    static let storyboardName = "Members"
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    let dataSource = MembersDatasource(orderByRisk: true)
    var ranges: [RiskScaleRange] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        title = "Team.Members.Teammates.CompareTeamRisk.title".localized
        dataSource.setRanges(ranges: ranges)
        HUD.show(.progress, onView: view)
        dataSource.loadData()
        dataSource.onUpdate = {
            HUD.hide()
            self.collectionView.reloadData()
        }
    }
    
    func registerCells() {
        collectionView.register(InfoHeader.nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: InfoHeader.cellID)
        collectionView.register(RiskCell.nib, forCellWithReuseIdentifier: RiskCell.cellID)
    }
}

extension CompareTeamRiskVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.itemsInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: RiskCell.cellID, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                               withReuseIdentifier: InfoHeader.cellID,
                                                               for: indexPath)
    }
}

extension CompareTeamRiskVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let model = dataSource[indexPath]
        if let cell = cell as? RiskCell {
            cell.nameLabel.text = model.name.entire
            cell.avatar.showAvatar(string: model.avatar)
            cell.itemLabel.text = model.model
            cell.riskLabel.text = model.risk.map { String(format: "%.2f", $0) } ?? ""
            let maxRow = dataSource.itemsInSection(section: indexPath.section)
            cell.cellSeparator.isHidden = indexPath.row == maxRow - 1
            
            if indexPath.row == 0 && indexPath.row == maxRow - 1 {
                ViewDecorator.shadow(for: cell, opacity: 0.05, radius: 8, offset: CGSize.init(width: 0, height: 0))
            } else if indexPath.row == 0 {
                ViewDecorator.shadow(for: cell, opacity: 0.05, radius: 4, offset: CGSize.init(width: 0, height: -4))
            } else if indexPath.row == maxRow - 1 {
                ViewDecorator.shadow(for: cell, opacity: 0.05, radius: 4, offset: CGSize.init(width: 0, height: 4))
            } else {
                ViewDecorator.removeShadow(for: cell)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if let header = view as? InfoHeader {
            header.leadingLabel.text = dataSource.headerTitle(indexPath: indexPath)
            header.trailingLabel.text = dataSource.headerSubtitle(indexPath: indexPath)
            header.trailingLabelTrailingConstraint.constant = 40
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        service.router.presentMemberProfile(teammateID: dataSource[indexPath].userID)
    }
}

extension CompareTeamRiskVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 71)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        if dataSource.itemsInSection(section: section) == 0 {
            return CGSize(width: collectionView.bounds.width, height: 0)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 50)
        }
    }
}
