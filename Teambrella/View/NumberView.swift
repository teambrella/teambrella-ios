//
//  NumberView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 27.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

@IBDesignable
class NumberView: UIView, XIBInitable {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var badgeLabel: Label!
    
    @IBOutlet var currencyToContainerConstraint: NSLayoutConstraint!
    @IBOutlet var currencyToBadgeConstraint: NSLayoutConstraint!
    
    @IBOutlet var currencyCenterConstraint: NSLayoutConstraint!
    
    var contentView: UIView!
    
    @IBInspectable
    var isBadgeVisible: Bool = true {
        didSet {
            badgeLabel.isHidden = !isBadgeVisible
            currencyToContainerConstraint.isActive = !isBadgeVisible
            currencyToBadgeConstraint.isActive = isBadgeVisible
        }
    }
    
    @IBInspectable
    var isCurrencyOnTop: Bool = true {
        didSet {
            currencyLabel.font = isCurrencyOnTop ? UIFont.boldSystemFont(ofSize: 9) : amountLabel.font
            if isCurrencyOnTop {
                currencyCenterConstraint.constant = -7
            } else {
                currencyCenterConstraint.constant = 0
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
}
