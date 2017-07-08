//
//  HomeApplicationDeniedCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 07.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class HomeApplicationDeniedCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var backView: RadarView!
    @IBOutlet var avatar: RoundImageView!
    @IBOutlet var yummigum: UIImageView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var centerLabel: UILabel!
    @IBOutlet var button: BorderedButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CellDecorator.roundedEdges(for: self)
        CellDecorator.shadow(for: self)
    }
}
