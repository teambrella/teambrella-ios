//
/* Copyright(C) 2017 Teambrella, Inc.
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

import Foundation

class VotingStatsDataSource: NSObject {
    weak var vc: VotingStatsVC?
    
    var list: [Decodable]? {
        didSet {
            onLoad?()
        }
    }
    
    var claimsVotes: [ClaimEntity] {
        get {return list as! [ClaimEntity]}
    }
    var risksVotes: [RiskVotesListEntry] {
        get {return list as! [RiskVotesListEntry]}
    }

    var count: Int {
        return list?.count ?? 0
    }
    let limit = 100
    
    // swiftlint:disable:next empty_count
    var isEmpty: Bool { return count == 0 }
    
    var onLoad: (() -> Void)?
    var onSelectItem: ((IndexPath) -> Void)?
    
    init(vc: VotingStatsVC) {
        super.init()
        self.vc = vc
        vc.collectionView.dataSource = self
        vc.collectionView.delegate = self
    }
    
    func loadData() {

        if vc!.isClaimsStats {
            service.dao.requestClaimsVotesList(teamID: vc!.teamID,
                                               offset: count,
                                               limit: limit,
                                               votesOfTeammateID: vc!.teammateID).observe { [weak self] result in
                switch result {
                case let .value(votesList):
                    if self?.count == 0 {
                        self?.list = votesList
                    }
                    else {
                        self?.list?.append(contentsOf: votesList)
                    }
                case let .error(error):
                    log(error)
                }
            }
        } else {
            service.dao.requestRisksVotesList(teamID: vc!.teamID,
                                              offset: count,
                                              limit: limit,
                                              teammateID: vc!.teammateID).observe { [weak self] result in
                switch result {
                case let .value(votesList):
                    if self?.count == 0 {
                        self?.list = votesList.votes
                    }
                    else {
                        self?.list?.append(contentsOf: votesList.votes)
                    }
                case let .error(error):
                    log(error)
                }
            }
        }
    }
    
    subscript(indexPath: IndexPath) -> Decodable? {
        return list?[indexPath.row]
    }
}

extension VotingStatsDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let isLast = indexPath.section == 0 || indexPath.row == count - 1

        if (indexPath.section == 0) {
            guard let cell = cell as? VotingStatsTopCell else { return }
            cell.update(with: vc!)
        } else {
            if vc!.isClaimsStats {
                guard let cell = cell as? ClaimsStatsCell else { return }
                cell.update(with: claimsVotes[indexPath.row])
                cell.cellSeparator.isHidden = isLast
            } else {
                guard let cell = cell as? RisksStatsCell else { return }
                cell.update(with: risksVotes[indexPath.row])
                cell.cellSeparator.isHidden = isLast
            }
        }
        
        ViewDecorator.decorateCollectionView(cell: cell,
                                             isFirst: indexPath.row == 0,
                                             isLast: isLast)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String, at indexPath: IndexPath) {
        guard let view = view as? InfoHeader else { return }
        guard !isEmpty else { return }

        view.leadingLabel.text = "Team.VotingRiskVC.numberBar.left".localized.uppercased()

        if vc!.isMe {
            view.trailingLabel.text = "Team.TeammateCell.IVote".localized.uppercased()
        } else {
            view.trailingLabel.text = "Team.TeammateCell.XVotes".localized(vc!.teammateName).uppercased()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectItem?(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section > 0
    }
}

extension VotingStatsDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "VotingStatsTopCell", for: indexPath)
        } else if vc!.isClaimsStats {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "ClaimsStatsCell", for: indexPath)
        } else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "RisksStatsCell", for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                   withReuseIdentifier: InfoHeader.cellID,
                                                                   for: indexPath)
        return view
    }
}

extension VotingStatsDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: indexPath.section == 0 ? 106 : 70)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0:
            return .zero
        default:
            return CGSize(width: collectionView.bounds.width, height: 30)
        }
    }
}
