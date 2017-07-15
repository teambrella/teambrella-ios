//
//  CompareTeamRiskVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 11.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import PKHUD
import UIKit

class CompareTeamRiskVC: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBar: UISearchBar!
    
    let dataSource = MembersDatasource(orderByRisk: true)
    lazy var router: MembersRouter = MembersRouter()
    var ranges: [RiskScaleEntity.Range] = []
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func registerCells() {
        collectionView.register(RiskTableHeader.nib,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: RiskTableHeader.cellID)
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
                                                               withReuseIdentifier: RiskTableHeader.cellID,
                                                               for: indexPath)
    }
}

extension CompareTeamRiskVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let model = dataSource[indexPath]
        if let cell = cell as? RiskCell {
            cell.nameLabel.text = model.name
            cell.avatar.showAvatar(string: model.avatar)
            cell.itemLabel.text = model.model
            cell.riskLabel.text = String(model.risk)
            let maxRow = dataSource.itemsInSection(section: indexPath.section)
            cell.cellSeparator.isHidden = indexPath.row == maxRow - 1
            
            if indexPath.row == 0 && indexPath.row == maxRow - 1 {
                CellDecorator.shadow(for: cell, opacity: 0.05, radius: 8, offset: CGSize.init(width: 0, height: 0))
            } else if indexPath.row == 0 {
                CellDecorator.shadow(for: cell, opacity: 0.05, radius: 4, offset: CGSize.init(width: 0, height: -4))
            } else if indexPath.row == maxRow - 1 {
                CellDecorator.shadow(for: cell, opacity: 0.05, radius: 4, offset: CGSize.init(width: 0, height: 4))
            } else {
                CellDecorator.removeShadow(for: cell)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if let header = view as? RiskTableHeader {
            header.leftLabel.text = dataSource.headerTitle(indexPath: indexPath)
            header.rightLabel.text = dataSource.headerSubtitle(indexPath: indexPath)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        MembersRouter().presentMemberProfile(teammate: dataSource[indexPath]    )
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
