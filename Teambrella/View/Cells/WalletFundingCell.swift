//
//  WalletFundingCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class WalletFundingCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var headerLabel: Label!
    @IBOutlet var infoButton: UIButton!
    @IBOutlet var upperNumberView: NumberView!
    @IBOutlet var upperCurrencyLabel: Label!
    @IBOutlet var lowerNumberView: NumberView!
    @IBOutlet var lowerCurrencyLabel: Label!
    @IBOutlet var barcodeButton: BorderedButton!
    @IBOutlet var fundWalletButton: BorderedButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
