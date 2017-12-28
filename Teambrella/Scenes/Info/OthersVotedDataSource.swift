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

class OthersVotedDataSource: NSObject {
    weak var vc: OthersVotedVC?
    
    var list: VotersList? {
        didSet {
            onLoad?()
        }
    }
    var count: Int {
        return list?.voters.count ?? 0
    }
    
    var onLoad: (() -> Void)?
    var onSelectItem: ((IndexPath) -> Void)?
    
    init(vc: OthersVotedVC) {
        super.init()
        self.vc = vc
        vc.collectionView.dataSource = self
        vc.collectionView.delegate = self
    }
    
    func loadData() {
        guard let teamID = vc?.teamID else { return }
        
        if let teammateID = vc?.teammateID {
            service.dao.requestTeammateOthersVoted(teamID: teamID,
                                                   teammateID: teammateID).observe { [weak self] result in
                                                    switch result {
                                                    case let .value(othersList):
                                                        self?.list = othersList
                                                    case let .error(error):
                                                        break
                                                    default:
                                                        break
                                                    }
            }
        } else if let claimID = vc?.claimID {
            service.dao.requestClaimOthersVoted(teamID: teamID, claimID: claimID).observe { [weak self] result in
                switch result {
                case let .value(othersList):
                    self?.list = othersList
                case let .error(error):
                    break
                default:
                    break
                }
            }
        }
    }
    
    subscript(indexPath: IndexPath) -> Voter? {
        guard let list = list else { return nil }
        
        switch indexPath.section {
        case 0:
            return  list.me
        default:
            return list.voters[indexPath.row]
        }
    }
}

extension OthersVotedDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let cell = cell as? OthersVotedCell else { return }
        guard let voter = self[indexPath] else { return }
        
        let model = OthersVotedCellModel(voter: voter)
        cell.update(with: model)
        let isLast = indexPath.section == 0 || indexPath.row == count - 1
        cell.separatorView.isHidden = isLast
        ViewDecorator.decorateCollectionView(cell: cell, isFirst: false, isLast: isLast)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String, at indexPath: IndexPath) {
        guard let view = view as? InfoHeader else { return }
        
        view.leadingLabel.text = "ALL VOTES"
        view.trailingLabel.text = "VOTES"
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectItem?(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section > 0
    }
}

extension OthersVotedDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return list?.me != nil ? 1 : 0
        default:
            return list?.voters.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OthersVotedCell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                   withReuseIdentifier: InfoHeader.cellID,
                                                                   for: indexPath)
        return view
    }
}

extension OthersVotedDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 70)
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
