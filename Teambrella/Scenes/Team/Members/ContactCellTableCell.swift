//
//  ContactCellTableCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ContactCellTableCell: UITableViewCell {
    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var topLabel: InfoLabel!
    @IBOutlet var bottomLabel: ItemNameLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
