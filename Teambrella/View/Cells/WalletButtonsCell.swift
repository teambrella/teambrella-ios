//
//  WalletButtonsCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class WalletButtonsCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var topView: UIView!
    @IBOutlet var topViewLabel: Label!
    @IBOutlet var imagesStack: RoundImagesStack!
    @IBOutlet var quantityLabel: Label!

    @IBOutlet var middleView: UIView!
    @IBOutlet var middleViewLabel: Label!
    
    @IBOutlet var bottomView: UIView!
    @IBOutlet var bottomViewLabel: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
