//
//  PrivateMessagesVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.08.17.
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
//

import UIKit

final class PrivateMessagesVC: UIViewController, Routable {
    static let storyboardName = "Home"
    
    @IBOutlet var collectionView: UICollectionView!
    let dataSource: PrivateMessagesDataSource = PrivateMessagesDataSource()
    weak var emptyVC: EmptyVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientNavBar()
        collectionView.dataSource = self
        collectionView.delegate = self
        PrivateMessagesCellBuilder.registerCells(in: collectionView)
        
        dataSource.onLoad = { [weak self] in
            self?.collectionView.reloadData()
            self?.showEmptyIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.reload()
        title = "Home.PrivateMessages.title".localized
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = nil
    }
    
    func showEmptyIfNeeded() {
        if dataSource.isEmpty {
            if emptyVC == nil {
                let frame = CGRect(x: self.collectionView.frame.origin.x, y: self.collectionView.frame.origin.y + 44,
                                   width: self.collectionView.frame.width,
                                   height: self.collectionView.frame.height - 44)
                emptyVC = EmptyVC.show(in: self, inView: self.view, frame: frame, animated: false)
                emptyVC?.setImage(image: #imageLiteral(resourceName: "iconInbox"))
                emptyVC?.setText(title: "Home.Empty.Title.noPrivateMessages".localized,
                                 subtitle: "Home.Empty.SubTitle.noPrivateMessages".localized)
            }
        } else {
            emptyVC?.remove()
            emptyVC = nil
        }
    }
    
}

extension PrivateMessagesVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return dataSource.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: PrivateChatUserCell.cellID, for: indexPath)
    }
}

extension PrivateMessagesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let user = dataSource.items[indexPath.row]
        PrivateMessagesCellBuilder.populate(cell: cell, with: user)
        let isLastCell = indexPath.row == dataSource.items.count - 1
        if let cell = cell as? PrivateChatUserCell {
            cell.cellSeparator.isHidden = isLastCell
        }
        ViewDecorator.decorateCollectionView(cell: cell,
                                             isFirst: indexPath.row == 0,
                                             isLast: isLastCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = dataSource.items[indexPath.row]
        service.router.presentChat(context: .privateChat(user), itemType: .privateChat)
    }
}

extension PrivateMessagesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 88)
    }
}
