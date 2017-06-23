//
//  WalletButtonsCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class WalletButtonsCell: UICollectionViewCell {
    @IBOutlet var topView: UIView!
    @IBOutlet var topViewLabel: ItemNameLabel!
    @IBOutlet var imagesStack: RoundImagesStack!
    @IBOutlet var quantityLabel: InfoHelpLabel!

    @IBOutlet var middleView: UIView!
    @IBOutlet var middleViewLabel: ItemNameLabel!
    
    @IBOutlet var bottomView: UIView!
    @IBOutlet var bottomViewLabel: ItemNameLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
