//
//  VotingScrollerCell.swift
//  Scroller
//
//  Created by Екатерина Рыжова on 28.06.17.
//  Copyright © 2017 Екатерина Рыжова. All rights reserved.
//

import UIKit

class VotingScrollerCell: UICollectionViewCell {

    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var centerLabel: UILabel!
    @IBOutlet var column: RoundedCornersView!
    @IBOutlet var columnHeightConstraint: NSLayoutConstraint!
    
    var isCentered: Bool = false
}
