//
//  TeamFeedCell.swift
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

import UIKit

class TeamFeedCell: UICollectionViewCell, XIBInitableCell {
    enum AvatarMode {
        case circular, roundedEdges
    }
    
    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var titleLabel: MessageTitleLabel!
    @IBOutlet var textLabel: MessageTextLabel!
    @IBOutlet var facesStack: RoundImagesStack!
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var typeLabel: InfoLabel!
    @IBOutlet var timeLabel: InfoLabel!
    @IBOutlet var unreadLabel: SubheaderLabel!
    @IBOutlet var pinnedView: UIImageView!
    @IBOutlet var cellSeparator: UIView!
    @IBOutlet var pane: UIView!
    @IBOutlet var avatarsConstraint: NSLayoutConstraint!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!

    var avatarMode: AvatarMode = .circular {
        didSet {
            avatarView.layer.cornerRadius = avatarMode == .circular ? 20 : 2
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
