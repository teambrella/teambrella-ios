//
//  TitleLabel.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

@IBDesignable
class TitleLabel: Label {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        textColor = .dark
        font = UIFont.boldSystemFont(ofSize: 15)
    }
}
