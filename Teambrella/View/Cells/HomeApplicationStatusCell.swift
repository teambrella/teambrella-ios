//
//  HomeApplicationStatusCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 07.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class HomeApplicationStatusCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var avatar: RoundImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var centerLabel: UILabel!
    @IBOutlet var bottomLabel: UILabel!
    @IBOutlet var messageCountLabel: UILabel!

    @IBAction func tapButton(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CellDecorator.roundedEdges(for: self)
        CellDecorator.shadow(for: self)
    }
}
