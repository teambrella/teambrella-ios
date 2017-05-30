//
//  ThreadPostCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 27.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ThreadPostCell: UITableViewCell {
    @IBOutlet var postLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dateLabel.textColor = .white50
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
