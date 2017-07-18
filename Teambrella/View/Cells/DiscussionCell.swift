//
//  DiscussionCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class DiscussionCell: UICollectionViewCell, XIBInitableCell {
    
    @IBOutlet var avatarView: RoundImageView!
    @IBOutlet var titleLabel: Label!
    @IBOutlet var textLabel: MessageTextLabel!
    
    @IBOutlet var timeLabel: Label!
    @IBOutlet var discussionLabel: Label!
    
    @IBOutlet var unreadCountView: RoundImageView!
    @IBOutlet var teammatesAvatarStack: RoundImagesStack!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CellDecorator.shadow(for: self)
    }
    
    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        contentView.layoutMargins = layoutMargins
    }
}
