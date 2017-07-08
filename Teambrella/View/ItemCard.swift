//
//  ItemCard.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 27.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

@IBDesignable
class ItemCard: UIView, XIBInitable {
    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        setup()
    }
    
    func setup() {
        avatarView.layer.cornerRadius = 2
        avatarView.layer.masksToBounds = true
    }
}
