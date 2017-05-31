//
//  TeammateObjectCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 31.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class TeammateObjectCell: UICollectionViewCell {
    @IBOutlet var titleLabel: Label!
    @IBOutlet var avatarView: UIImageView!
    
    @IBOutlet var nameLabel: Label!
    @IBOutlet var statusLabel: Label!
    @IBOutlet var detailsLabel: Label!
    
    @IBOutlet var leftNumberView: NumberView!
    @IBOutlet var centerNumberView: NumberView!
    @IBOutlet var rightNumberView: NumberView!
    @IBOutlet var button: BorderedButton!
    
}

