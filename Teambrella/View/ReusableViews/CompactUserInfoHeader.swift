//
//  CompactUserInfoHeader.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 15.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class CompactUserInfoHeader: UICollectionReusableView, XIBInitableCell {
    @IBOutlet var leftNumberView: NumberView!
    @IBOutlet var rightNumberView: NumberView!
    @IBOutlet var avatarView: RoundImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
