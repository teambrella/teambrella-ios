//
//  PrivateChatUserCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class PrivateChatUserCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var avatarView: RoundImageView!
    @IBOutlet var nameLabel: MessageTitleLabel!
    @IBOutlet var messageLabel: MessageTextLabel!
    @IBOutlet var timeLabel: InfoLabel!
    @IBOutlet var unreadCountView: RoundImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
