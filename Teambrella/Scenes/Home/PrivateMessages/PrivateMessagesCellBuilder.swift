//
//  PrivateMessagesCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.08.17.
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
            cell.unreadCountView.isHidden = model.unreadCount == 0
        }
    }
    
}
