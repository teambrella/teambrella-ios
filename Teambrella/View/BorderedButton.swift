//
//  BorderedButton.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 27.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedButton: UIButton {
    @IBInspectable
    var borderColor: UIColor = .robinEggBlue {
        didSet {
            setup()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        layer.masksToBounds = true
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = borderColor.cgColor
    }
}
