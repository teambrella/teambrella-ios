//
//  FeedCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.

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

import Foundation
import Kingfisher

struct FeedCellBuilder {
    static func populate(cell: UICollectionViewCell, with model: FeedEntity) {
        if let cell = cell as? TeamFeedCell {
            if model.itemType == .teammate {
                cell.avatarView.showAvatar(string: model.smallPhotoOrAvatar)
                cell.avatarView.layer.masksToBounds = true
                cell.avatarView.layer.cornerRadius = cell.avatarView.frame.height / 2
            } else {
                cell.avatarView.showImage(string: model.smallPhotoOrAvatar)
                cell.avatarView.layer.masksToBounds = true
                cell.avatarView.layer.cornerRadius = 4
            }
            cell.avatarView.contentMode = .scaleAspectFill
            cell.titleLabel.text = model.chatTitle
            cell.textLabel.text = model.text
            cell.facesStack.setAvatars(images: model.topPosterAvatars, label: nil, max: 4)
         
            if let date = model.itemDate {
            cell.timeLabel.text = DateProcessor().stringInterval(from: date).uppercased()
            }
            cell.unreadLabel.text = String(model.unreadCount)
            cell.unreadLabel.isHidden = model.unreadCount == 0
            
            cell.titleLabel.text = model.chatTitle ?? model.modelOrName
            
            switch model.itemType {
            case .claim:
                cell.iconView.image = #imageLiteral(resourceName: "claim")
                cell.typeLabel.text = "Team.Chat.TypeLabel.claim".localized
            case .teammate:
                cell.iconView.image = #imageLiteral(resourceName: "application")
                cell.typeLabel.text = "Team.Chat.TypeLabel.application".localized
            case .teamChat:
                cell.iconView.image = #imageLiteral(resourceName: "discussion")
                cell.typeLabel.text = "Team.Chat.TypeLabel.discussion".localized
            default:
                cell.iconView.image = nil
                cell.typeLabel.text = "Team.Chat.TypeLabel.other".localized
            }
            
        }
    }

}
