//
//  ProxyCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ProxyCell: UICollectionViewCell {
    @IBOutlet var avatarView: RoundBadgedView!
    @IBOutlet var nameLabel: MessageTitleLabel!
    @IBOutlet var detailsLabel: InfoLabel!
    @IBOutlet var timeLabel: MessageTitleLabel!
    @IBOutlet var rankLabel: InfoLabel!
    @IBOutlet var leftBar: ScaleBar!
    @IBOutlet var middleBar: ScaleBar!
    @IBOutlet var rightBar: ScaleBar!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
