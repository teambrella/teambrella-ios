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
    @IBOutlet var avatar1: RoundImageView!
    @IBOutlet var avatar2: RoundImageView!
    @IBOutlet var avatar3: RoundImageView!
    @IBOutlet var avatar4: RoundImageView!
    @IBOutlet var avatar5: RoundImageView!
    @IBOutlet var avatar6: RoundImageView!
    @IBOutlet var avatar7: RoundImageView!
    @IBOutlet var avatar8: RoundImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.text = "team info".uppercased()
        numberBar.left?.titleLabel.text = "Members".uppercased()
        numberBar.left?.amountLabel.text = "159"
        numberBar.left?.currencyLabel.text = ""
        numberBar.left?.badgeLabel.text = ""
        numberBar.right?.titleLabel.text = "Discussions".uppercased()
        numberBar.right?.amountLabel.text = "24"
        numberBar.right?.currencyLabel.text = ""
        numberBar.right?.badgeLabel.text = ""
        rulesButton.setTitle("Read Team Rules", for: .normal)
    }

}
