//
//  TeammateProfileVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Kingfisher
import UIKit

class TeammateProfileVC: UIViewController, Routable {
    struct Constant {
        static let socialCellHeight: CGFloat = 44
    }
    
    static var storyboardName: String = "Team"
    
    var teammate: TeammateLike {
        get { return self.dataSource.teammate }
        set { if self.dataSource == nil {
            self.dataSource = TeammateProfileDataSource(teammate: newValue)
            }
        }
    }
    
    var dataSource: TeammateProfileDataSource!
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        dataSource.loadEntireTeammate { [weak self] in
            self?.collectionView.reloadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showClaims(sender: UIButton) {
        if let claimCount = teammate.extended?.object.claimCount,
            claimCount == 1,
            let claimID = teammate.extended?.object.singleClaimID {
            TeamRouter().presentClaim(claimID: claimID)
        } else {
            MembersRouter().presentClaims(teammate: teammate)
        }
    }
    
    func registerCells() {
        collectionView.register(DiscussionCell.nib, forCellWithReuseIdentifier: TeammateProfileCellType.dialog.rawValue)
    }
    
}

// MARK: UICollectionViewDataSource
extension TeammateProfileVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.rows(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = dataSource.type(for: indexPath).rawValue
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                   withReuseIdentifier: "Header",
                                                                   for: indexPath)
        return view
    }
    
}

// MARK: UICollectionViewDelegate
extension TeammateProfileVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        TeammateCellBuilder.populate(cell: cell, with: teammate, delegate: self)
        
        // add handlers
        if let cell = cell as? TeammateObjectCell {
            cell.button.removeTarget(nil, action: nil, for: .allEvents)
            cell.button.addTarget(self, action: #selector(showClaims), for: .touchUpInside)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let identifier = dataSource.type(for: indexPath)
        if identifier == .dialog {
            TeamRouter().presentChat(teammate: teammate)
        }
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout
extension TeammateProfileVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let wdt = collectionView.bounds.width - 16 * 2
        switch dataSource.type(for: indexPath) {
        case .summary:
            return CGSize(width: collectionView.bounds.width, height: 210)
        case .object:
            return CGSize(width: wdt, height: 296)
        case .stats:
            return CGSize(width: wdt, height: 368)
        case .contact:
            let base: CGFloat = 44
            let cellHeight: CGFloat = Constant.socialCellHeight
            return CGSize(width: wdt, height: base + CGFloat(dataSource.socialItems.count) * cellHeight)
        case .dialog:
            return CGSize(width: wdt, height: 120)
        }
    }
    
    //    func collectionView(_ collectionView: UICollectionView,
    //                        layout collectionViewLayout: UICollectionViewLayout,
    //                        referenceSizeForHeaderInSection section: Int) -> CGSize {
    //        return CGSize(width: collectionView.bounds.width, height: 1)
    //    }
}

extension TeammateProfileVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.socialItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ContactCellTableCell", for: indexPath)
    }
}

extension TeammateProfileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ContactCellTableCell else { return }
        
        let item = dataSource.socialItems[indexPath.row]
        cell.avatarView.image = item.icon
        cell.topLabel.text = item.name.uppercased()
        cell.bottomLabel.text = item.address
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.socialCellHeight
    }
}
