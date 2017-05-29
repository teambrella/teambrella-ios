//
//  MembersVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import SwiftyJSON
import UIKit
import XLPagerTabStrip

class MembersVC: UIViewController, IndicatorInfoProvider {
    @IBOutlet var collectionView: UICollectionView!
    let dataSource = MembersDatasource()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.onUpdate = {
            self.collectionView.reloadData()
        }
        dataSource.loadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Members")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

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
            if let cell = cell as? TeammateCandidateCell {
                
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
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                   withReuseIdentifier: "TeammatesHeader",
                                                                   for: indexPath)
        return view
    }
    
}

extension MembersVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let item = dataSource[indexPath]
        if let cell = cell as? TeammateCandidateCell {
            cell.titleLabel.text = item.name
        } else if let cell = cell as? TeammateCandidateCell {
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        if let view = view as? TeammateHeaderView {
            view.titleLabel.text = dataSource.headerTitle(indexPath: indexPath)
            view.subtitleLabel.text = dataSource.headerSubtitle(indexPath: indexPath)
        }
    }
    
}

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

class MembersDatasource {
    enum TeammateSectionType {
    case new, teammate
    }
    
    var newTeammates: [TeammateLike] = []
    var teammates: [TeammateLike] = []
    var onUpdate: (() -> Void)?
    
    var sections: Int {
       var count = 2
        if newTeammates.isEmpty  { count -= 1 }
        if teammates.isEmpty { count -= 1 }
        return count
    }
    
    func type(indexPath: IndexPath) -> TeammateSectionType {
        switch indexPath.section {
        case 0:
            return newTeammates.isEmpty ? .teammate : .new
        default:
            return .teammate
        }
    }
    
    func itemsInSection(section: Int) -> Int {
        switch section {
        case 0:
            return newTeammates.isEmpty ? teammates.count : newTeammates.count
        case 1:
            return teammates.count
        default:
            break
        }
        return 0
    }
    
    func headerTitle(indexPath: IndexPath) -> String {
        switch type(indexPath: indexPath) {
        case .new:
            return "NEW TEAMMATES"
        case .teammate:
            return "TEAMMATES"
        }
    }
    
    func headerSubtitle(indexPath: IndexPath) -> String {
        switch type(indexPath: indexPath) {
        case .new:
            return "VOTING ENDS IN"
        case .teammate:
            return "NET"
        }
    }
    
    func loadData() {
        fakeLoadData()
    }
    
    subscript(indexPath: IndexPath) -> TeammateLike {
        switch type(indexPath: indexPath) {
        case .new:
            return newTeammates[indexPath.row]
        case .teammate:
            return teammates[indexPath.row]
        }
    }
    
    func fakeLoadData() {
        for i in 0...20 {
            let teammate = FakeTeammate(json: JSON(""))
            if teammate.isJoining {
                newTeammates.append(teammate)
            } else {
                teammates.append(teammate)
            }
        }
        onUpdate?()
    }
    
}

final class FakeTeammate: TeammateLike {
    var ver: Int64 = 0
    let id: String = "666"
    
    let claimLimit: Int = 0
    let claimsCount: Int = 0
    let isJoining: Bool = Random.bool
    let isVoting: Bool = false
    let model: String = "Fake"
    let name: String = "Fake"
    let risk: Double = 0
    let riskVoted: Double = 0
    let totallyPaid: Double = 0
    let hasUnread: Bool = Random.bool
    let userID: String = "666"
    let year: Int = 0
    let avatar: String = ""
    
    var extended: ExtendedTeammate?
    
    var description: String {
        return "Fake Teammate"
    }
    
    var isComplete: Bool { return extended != nil }
    
    init(json: JSON) {
    }
}
