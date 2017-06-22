//
//  UserIndexCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class UserIndexCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var avatarView: RoundBadgedView!
    @IBOutlet var nameLabel: Label!
    @IBOutlet var detailsLabel: Label!
    @IBOutlet var amountLabel: Label!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
