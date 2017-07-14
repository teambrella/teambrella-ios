//
//  FeedCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
            cell.titleLabel.text = model.chatTitle
            cell.textLabel.text = model.text
            cell.facesStack.setAvatars(images: model.topPosterAvatars, label: nil, max: 4)
         
            if let date = model.itemDate {
            cell.timeLabel.text = DateProcessor().stringInterval(from: date)
            }
            cell.unreadLabel.text = String(model.unreadCount)
            cell.unreadLabel.isHidden = model.unreadCount == 0
            
            cell.titleLabel.text = model.chatTitle ?? model.modelOrName
            
            switch model.itemType {
            case .claim:
                cell.iconView.image = #imageLiteral(resourceName: "claim")
                cell.typeLabel.text = "CLAIM"
            case .teammate:
                cell.iconView.image = #imageLiteral(resourceName: "application")
                cell.typeLabel.text = "APPLICATION"
            default:
                cell.iconView.image = nil
                cell.typeLabel.text = "UNKNOWN"
            }
            
        }
    }

}
