//
//  TeammateDiscussionCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class TeammateDiscussionCell: UICollectionViewCell {
    @IBOutlet var avatarView: RoundImageView!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var textLabel: MessageTextLabel!
    
    @IBOutlet var timeLabel: Label!
    @IBOutlet var discussionLabel: Label!
    
    @IBOutlet var unreadCountView: RoundImageView!
    @IBOutlet var teammatesAvatarStack: RoundImagesStack!
    
}
