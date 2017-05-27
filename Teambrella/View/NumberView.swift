//
//  NumberView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 27.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class NumberView: UIView, XIBInitable {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var badgeLabel: Label!
    
    var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
}
