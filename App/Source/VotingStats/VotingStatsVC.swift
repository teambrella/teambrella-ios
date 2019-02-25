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

import PKHUD
import UIKit

class VotingStatsVC: UIViewController, Routable {
    static let storyboardName: String = "Info"
    
    var teamID: Int = -1
    var teammateID: Int = -1
    var teammateName: String = ""
    var voteAsTeamOrBetter: Double = -1
    var voteAsTeam: Double = -1
    var isClaimsStats: Bool = false
    var isMe: Bool = false
    
    @IBOutlet var collectionView: UICollectionView!
    var dataSource: VotingStatsDataSource!
    weak var emptyVC: EmptyVC?
    
    var router: MainRouter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientNavBar()
        HUD.show(.progress, onView: view)

        setupCollectionView()
        dataSource = VotingStatsDataSource(vc: self)
        dataSource.onLoad = { [weak self] in
            HUD.hide()
            self?.collectionView.reloadData()
            self?.showEmptyIfNeeded()
        }
        dataSource.onSelectItem = { [weak self] indexPath in
            if (self?.isClaimsStats ?? false) {
                if let claim = self?.dataSource[indexPath] as? ClaimEntity {
                    self?.router.presentClaim(claim: claim)
                }
            } else {
                if let riskEntry = self?.dataSource[indexPath] as? RiskVotesListEntry {
                    self?.router.presentMemberProfile(teammateID: riskEntry.userID)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isMe {
            title = (isClaimsStats ? "Team.VotingStats.IVotePayouts" : "Team.VotingStats.IVoteRisks").localized
        } else {
            title = (isClaimsStats ? "Team.VotingStats.XVotesPayouts" : "Team.VotingStats.XVotesRisks").localized
        }

        dataSource.loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = "Main.back".localized
    }
    
    func showEmptyIfNeeded() {
        if dataSource.isEmpty {
            if emptyVC == nil {
                let frame = CGRect(x: self.collectionView.frame.origin.x, y: self.collectionView.frame.origin.y + 44,
                                   width: self.collectionView.frame.width,
                                   height: self.collectionView.frame.height - 44)
                emptyVC = EmptyVC.show(in: self, inView: self.view, frame: frame, animated: false)
                emptyVC?.setImage(image: #imageLiteral(resourceName: "iconVote"))
                emptyVC?.setText(title: "Team.OthersVoted.Empty.title".localized,
                                 subtitle: "Team.OthersVoted.Empty.details".localized)
            }
        } else {
            emptyVC?.remove()
            emptyVC = nil
        }
    }
    
    private func setupCollectionView() {
        collectionView.register(InfoHeader.nib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: InfoHeader.cellID)
    }
    
}
