//
//  PrivateMessagesVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class PrivateMessagesVC: UIViewController, Routable {
    static let storyboardName = "Home"
    
    @IBOutlet var collectionView: UICollectionView!
    let dataSource: PrivateMessagesDataSource = PrivateMessagesDataSource()
    weak var emptyVC: EmptyVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientNavBar()
        title = "Home.PrivateMessages.title".localized
        collectionView.dataSource = self
        collectionView.delegate = self
        PrivateMessagesCellBuilder.registerCells(in: collectionView)
        
        dataSource.onLoad = { [weak self] in
            self?.collectionView.reloadData()
            self?.showEmptyIfNeeded()
        }
        dataSource.loadNext()
    }
    
    func showEmptyIfNeeded() {
        if dataSource.isEmpty && emptyVC == nil {
            emptyVC = EmptyVC.show(in: self)
            emptyVC?.setText(title: "Home.Empty.Title.noPrivateMessages".localized, subtitle: nil)
        } else {
            emptyVC?.remove()
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = dataSource.items[indexPath.row]
        service.router.presentChat(context: .privateChat(user))
    }
}

extension PrivateMessagesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 88)
    }
}
