//
//  NumberView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 27.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class NumberView: UIView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var badgeLabel: Label!
    
//    var isBadgeVisible: Bool = false {
//        didSet {
////            noBadgeConstraint.isActive = !isBadgeVisible
////            badgeIntervalConstraint.isActive = isBadgeVisible
//            badgeLabel.isHidden = !isBadgeVisible
//        }
//    }
//    
//    var isCurrencyOnTop: Bool = false {
//        didSet {
////            currencyOnTopConstraint.isActive = isCurrencyOnTop
////            currencySameAsAmountConstraint.isActive = !isCurrencyOnTop
//            
//            currencyLabel.font = isCurrencyOnTop ? UIFont.boldSystemFont(ofSize: 9) : currencyLabel.font
//        }
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        if tag == 676 { return self }
        guard let view = Bundle.main.loadNibNamed("NumberView", owner: nil, options: nil)?.first as? UIView else {
            return nil
        }
        
        view.frame = self.frame
        view.autoresizingMask = self.autoresizingMask
        view.translatesAutoresizingMaskIntoConstraints = self.translatesAutoresizingMaskIntoConstraints
        view.tag = self.tag
        return view
    }
    
}
