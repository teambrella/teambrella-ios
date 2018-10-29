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
            cell.avatarView.show(model.avatar)
            cell.nameLabel.text = model.name
            cell.messageLabel.text = model.text
            let minutes = model.minutesSinceLast
            switch minutes {
            case 0:
                cell.timeLabel.text = "Team.TeammateCell.timeLabel.justNow".localized
            case 1..<60:
                cell.timeLabel.text = "Team.Ago.minutes_format".localized(minutes)
            case 60..<(60 * 24):
                cell.timeLabel.text = "Team.Ago.hours_format".localized(minutes / 60)
            case 1440...10080: // minutes in a day ... minutes in a week
                cell.timeLabel.text = "Team.Ago.days_format".localized(minutes / (60 * 24))
            default:
                let date = Date().addingTimeInterval(TimeInterval(-minutes * 60))
                cell.timeLabel.text = DateProcessor().stringIntervalOrDate(from: date)
            }
            cell.unreadCountView.text = String(model.unreadCount)
            cell.unreadCountView.isHidden = model.unreadCount == 0
        }
    }
    
}
