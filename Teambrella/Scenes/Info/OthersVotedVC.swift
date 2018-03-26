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

class OthersVotedVC: UIViewController, Routable {
    static let storyboardName: String = "Info"
    
    var teamID: Int?
    var teammateID: Int?
    var claimID: Int?
    
    @IBOutlet var collectionView: UICollectionView!
    var dataSource: OthersVotedDataSource!
    weak var emptyVC: EmptyVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientNavBar()
        HUD.show(.progress, onView: view)
        title = "Info.OthersVoted.title".localized
        setupCollectionView()
        dataSource = OthersVotedDataSource(vc: self)
        dataSource.onLoad = { [weak self] in
            HUD.hide()
            self?.collectionView.reloadData()
            self?.showEmptyIfNeeded()
        }
        dataSource.onSelectItem = { [weak self] indexPath in
            if let voter = self?.dataSource[indexPath] {
                service.router.presentMemberProfile(teammateID: voter.userID)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.loadData()
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
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: InfoHeader.cellID)
    }
    
}
