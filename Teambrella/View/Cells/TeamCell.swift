//
//  TeamCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 13.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class TeamCell: UITableViewCell, XIBInitableCell {
    @IBOutlet var container: UIView!
    @IBOutlet var teamIcon: UIImageView!
    @IBOutlet var incomingCount: Label!
    @IBOutlet var teamName: UILabel!
    @IBOutlet var itemName: UILabel!
    @IBOutlet var coverage: UILabel!
    @IBOutlet var tick: UIImageView!
    @IBOutlet var iconCoverage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        teamIcon.layer.cornerRadius = 3
        incomingCount.layer.borderWidth = 1.5
        incomingCount.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
    }
    
}
