//
//  ReportItemCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ReportItemCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var headerLabel: Label!
    @IBOutlet var itemLabel: Label!
    @IBOutlet var detailsLabel: Label!
    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var infoButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
