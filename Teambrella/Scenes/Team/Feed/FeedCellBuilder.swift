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
            /*
            cell.avatarView.kf.setImage(with: URL(string: model.avatar))
            cell.titleLabel.text = model.title
            cell.textLabel.text = model.text
            let urls = model.teammatesAvatars.flatMap { URL(string: $0) }
            cell.facesStack.set(images: urls, label: nil, max: 4)
            cell.timeLabel.text = "\(model.lastPostedMinutes) MIN AGO"
            cell.unreadLabel.text = String(model.unreadCount)
            switch model.type {
            case .claim:
                cell.iconView.image = #imageLiteral(resourceName: "claim")
                cell.typeLabel.text = "CLAIM"
            case .teammate:
                cell.iconView.image = #imageLiteral(resourceName: "application")
                cell.typeLabel.text = "APPLICATION"
            case .topic:
                cell.iconView.image = #imageLiteral(resourceName: "rules")
                cell.typeLabel.text = "RULES"
            }
            
             */
        }
    }

}
