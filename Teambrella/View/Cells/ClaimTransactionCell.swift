//
//  ClaimTransactionCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 29.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ClaimTransactionCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var container: UIView!
    @IBOutlet var avatar: RoundBadgedView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var amountCrypto: UILabel!
    @IBOutlet var cryptoAmountLabel: UILabel!
    @IBOutlet var amountFiat: UILabel!
    @IBOutlet var fiatAmountLabel: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
