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
        
        dataSource.loadEntireTeammate { [weak self] in
            self?.collectionView.reloadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        if let cell = cell as? TeammateSummaryCell {
            cell.title.text = teammate.name
            
            let url = URL(string: service.server.avatarURLstring(for: teammate.avatar))
            cell.avatarView.kf.setImage(with: url)
            
            cell.leftNumberView.titleLabel.text = "COVERS ME"
            
            cell.rightNumberView.titleLabel.text = "COVER THEM"
            teammate.extended?.maxPaymentFiat.map { cell.leftNumberView.amountLabel.text = "\($0)" }
        } else if let cell = cell as? TeammateObjectCell {
            if let imageString = teammate.extended?.smallPhotos?.first {
                let url = URL(string: service.server.avatarURLstring(for: imageString))
                cell.avatarView.kf.setImage(with: url)
            }
            cell.nameLabel.text = "\(teammate.model), \(teammate.year)"
            
            cell.leftNumberView.titleLabel.text = "LIMIT"
            cell.centerNumberView.titleLabel.text = "NET"
            cell.rightNumberView.titleLabel.text = "RISK FACTOR"
        }
        
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
            return CGSize(width: wdt, height: 244)
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
