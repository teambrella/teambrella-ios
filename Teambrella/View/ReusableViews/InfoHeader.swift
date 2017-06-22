//
//  InfoHeader.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class InfoHeader: UICollectionReusableView, XIBInitableCell {
    @IBOutlet var leadingLabel: Label!
    @IBOutlet var trailingLabel: Label!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
