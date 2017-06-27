//
//  MeCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 27.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class MeCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var radarView: RadarView!
    @IBOutlet var avatar: RoundImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var twitterButton: UIButton!
    @IBOutlet var emailButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
