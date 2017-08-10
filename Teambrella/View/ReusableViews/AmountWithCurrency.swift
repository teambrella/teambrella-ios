//
//  AmountWithCurrency.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 20.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

@IBDesignable
class AmountWithCurrency: UIView, XIBInitable {
    @IBOutlet var contentView: UIView!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

}
