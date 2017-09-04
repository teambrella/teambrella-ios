//
//  WalletTransactionCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 01.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class WalletTransactionCell: UICollectionViewCell, XIBInitableCell {

    @IBOutlet var container: UIView!
    @IBOutlet var createdLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var kindTitle: UILabel!
    @IBOutlet var kindLabel: UILabel!
    @IBOutlet var statusTitle: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var amountTitle: UILabel!
    @IBOutlet var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
