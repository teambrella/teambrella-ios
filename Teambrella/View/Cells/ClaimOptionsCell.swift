//
//  ClaimOptionsCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ClaimOptionsCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var allVotesLabel: Label!
    @IBOutlet var cashFlowLabel: Label!
    @IBOutlet var transactionsLabel: Label!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
