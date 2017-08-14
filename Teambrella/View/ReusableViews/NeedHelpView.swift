//
//  NeedHelpView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class NeedHelpView: UICollectionReusableView, XIBInitableCell {
    @IBOutlet var label: InfoLabel!
    @IBOutlet var infoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
