//
//  JoinTeamInfoCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 01.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class JoinTeamInfoCell: UICollectionViewCell {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var numberBar: NumberBar!
    @IBOutlet var rulesButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.text = "team info".uppercased()
        numberBar.left?.badgeLabel.text = "Members".uppercased()
        numberBar.left?.amountLabel.text = "159"
        numberBar.right?.badgeLabel.text = "Discussions".uppercased()
        numberBar.right?.amountLabel.text = "24"
        rulesButton.setTitle("Read Team Rules", for: .normal)
    }

}
