//
//  PlainButton.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

@IBDesignable
class PlainButton: UIButton {
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
        layer.cornerRadius = 3
        backgroundColor = #colorLiteral(red: 0.2862745098, green: 0.3490196078, blue: 0.9019607843, alpha: 0.4016213613)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.teambrellaBold(size: 15)
    }
}
