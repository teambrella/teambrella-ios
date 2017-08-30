//
//  PrivateMessagesCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

struct PrivateMessagesCellBuilder {
    static func registerCells(in collectionView: UICollectionView) {
        collectionView.register(PrivateChatUserCell.nib, forCellWithReuseIdentifier: PrivateChatUserCell.cellID)
    }
    
    static func populate(cell: UICollectionViewCell, with model: PrivateChatUser) {
        if let cell = cell as? PrivateChatUserCell {
            cell.avatarView.showAvatar(string: model.avatar)
            cell.nameLabel.text = model.name
            cell.messageLabel.text = model.text
            cell.timeLabel.text = DateProcessor().stringFromNow(minutes: model.minutesSinceLast)
            cell.unreadCountView.text = String(model.unreadCount)
        }
    }
    
}
