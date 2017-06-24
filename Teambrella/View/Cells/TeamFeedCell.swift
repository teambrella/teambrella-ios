//
//  TeamFeedCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
    @IBOutlet var unreadLabel: UILabel!
   
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
