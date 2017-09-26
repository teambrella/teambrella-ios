//
//  SwitchUserCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 26.09.2017.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class SwitchUserCell: UITableViewCell, XIBInitableCell {
    @IBOutlet var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
