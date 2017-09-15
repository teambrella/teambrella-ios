//
//  WalletCosignerCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 15.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class WalletCosignerCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var container: UIView!
    @IBOutlet var avatar: RoundBadgedView!
    @IBOutlet var nameLabel: Label!
    @IBOutlet var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
