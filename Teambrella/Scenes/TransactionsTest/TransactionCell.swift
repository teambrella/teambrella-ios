//
//  TransactionCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 04.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var claimNameLabel: UILabel!
    @IBOutlet var signButton: UIButton!
    @IBOutlet var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
