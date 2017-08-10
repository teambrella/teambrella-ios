//
//  AmountWithCurrency.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 20.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class AmountWithCurrency: UIView, XIBInitable {
    @IBOutlet var contentView: UIView!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

}
