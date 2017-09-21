//
//  VotingChartCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 21.09.2017.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class VotingChartCell: UICollectionViewCell {
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var centerLabel: UILabel!
    @IBOutlet var column: RoundedCornersView!
    @IBOutlet var columnHeightConstraint: NSLayoutConstraint!
    
    var isCentered: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
