//
//  TeammateSummaryCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 31.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class TeammateSummaryCell: UICollectionViewCell {
    @IBOutlet var avatarView: RoundImageView!
    @IBOutlet var infoLabel: Label!
    @IBOutlet var leftNumberView: NumberView!
    @IBOutlet var rightNumberView: NumberView!
    @IBOutlet var title: Label!
    @IBOutlet var subtitle: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CellDecorator.shadow(for: self)
    }
    
}
