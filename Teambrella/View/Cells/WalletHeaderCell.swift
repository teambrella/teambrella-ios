//
//  WalletHeaderCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class WalletHeaderCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var amount: WalletAmountLabel!
    @IBOutlet var auxillaryAmount: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var numberBar: NumberBar!
    @IBOutlet var button: BorderedButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        numberBar.left?.alignmentType = .leading
    }

}
