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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientNavBar()
        title = "Inbox"
        collectionView.dataSource = self
        collectionView.delegate = self
        PrivateMessagesCellBuilder.registerCells(in: collectionView)
        
        dataSource.onLoad = { [weak self] in
            self?.collectionView.reloadData()
        }
        dataSource.loadNext()
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
}

extension PrivateMessagesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 88)
    }
}
