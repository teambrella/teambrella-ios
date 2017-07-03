//
//  JoinTeamInfoCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 01.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class JoinTeamInfoCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var numberBar: NumberBar!
    @IBOutlet var rulesButton: BorderedButton!
    @IBOutlet var container: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.text = "team info".uppercased()
        numberBar.left?.titleLabel.text = "Members".uppercased()
        numberBar.left?.amountLabel.text = "159"
        numberBar.left?.currencyLabel.isHidden = true
        numberBar.left?.badgeLabel.isHidden = true
        numberBar.right?.titleLabel.text = "Discussions".uppercased()
        numberBar.right?.amountLabel.text = "24"
        numberBar.right?.currencyLabel.isHidden = true
        numberBar.right?.badgeLabel.isHidden = true
        rulesButton.setTitle("Read Team Rules", for: .normal)
    }

}
