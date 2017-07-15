//
//  DiscussionCompactCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 15.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class DiscussionCompactCell: UICollectionViewCell {
    @IBOutlet var avatarView: RoundImageView!
    @IBOutlet var unreadCountView: RoundImageView!
    @IBOutlet var timeLabel: InfoLabel!
    @IBOutlet var titleLabel: MessageTitleLabel!
    @IBOutlet var textLabel: MessageTextLabel!
    
}
