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
    
    var isMe: Bool = false
    var teammate: TeammateLike {
        get { return self.dataSource.teammate }
        set { if self.dataSource == nil {
            self.dataSource = TeammateProfileDataSource(teammate: newValue, isMe: self.isMe)
            }
        }
    }
    
    var dataSource: TeammateProfileDataSource!
    var riskController: VotingRiskVC?
    var linearFunction: PiecewiseFunction?
    var chosenRisk: Double?
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        dataSource.loadEntireTeammate { [weak self] in
            self?.prepareLinearFunction()
            self?.collectionView.reloadData()
        }
        
    }
    
    func prepareLinearFunction() {
        guard let risk = teammate.extended?.riskScale else { return }
        
        let function = PiecewiseFunction((0.2, risk.coversIfMin), (1, risk.coversIf1), (5, risk.coversIfMax))
        linearFunction = function
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
        collectionView.register(MeCell.nib, forCellWithReuseIdentifier: TeammateProfileCellType.me.rawValue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToVotingRisk",
            let vc = segue.destination as? VotingRiskVC {
            riskController = vc
        }
    }
    
    func updateAmounts(with risk: Double) {
        chosenRisk = risk
        let cells = collectionView.visibleCells.filter { $0 is TeammateSummaryCell }
        guard let cell = cells.first as? TeammateSummaryCell else { return }
        guard let myRisk = teammate.extended?.riskScale?.myRisk,
            let theirRisk = teammate.extended?.basic.risk else { return }
        
        if let theirAmount = linearFunction?.value(at: risk / theirRisk * myRisk) {
            cell.leftNumberView.amountLabel.text = String(format: "%.2f", theirAmount)
        }
        if let myAmount = linearFunction?.value(at: risk / myRisk * theirRisk) {
            cell.rightNumberView.amountLabel.text = String(format: "%.2f", myAmount)
        }
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
        } else if let cell = cell as? TeammateVoteCell, let riskController = riskController {
            if let voting = teammate.extended?.voting {
                riskController.timeLabel.text = "\(voting.remainingMinutes) MIN"
            }
            riskController.teammate = teammate
            riskController.onVoteUpdate = { [weak self] risk in
                guard let me = self else { return }
                
                me.updateAmounts(with: risk)
            }
            
            riskController.onVoteConfirmed = { [weak self] risk in
                guard let me = self else { return }
                
                me.riskController?.yourRiskValue.alpha = 0.5
                me.dataSource.sendRisk(teammateID: me.teammate.id, risk: risk, completion: {
                    me.riskController?.yourRiskValue.alpha = 1
                })
            }
        }
        // self.updateAmounts(with: risk)
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
        case .me:
            return CGSize(width: collectionView.bounds.width, height: 210)
        case .voting:
            return CGSize(width: wdt, height: 350)
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
        if let cell = cell as? ContactCellTableCell {
            let item = dataSource.socialItems[indexPath.row]
            cell.avatarView.image = item.icon
            cell.topLabel.text = item.name.uppercased()
            cell.bottomLabel.text = item.address
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.socialCellHeight
    }
}
