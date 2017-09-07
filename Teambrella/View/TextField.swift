//
//  TextField.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class TextField: UITextField {
    var alertBorderColor: UIColor = .red
    var normalBorderColor: UIColor = .cloudyBlue
    var isInAlertMode: Bool = false {
        didSet {
        layer.borderWidth = 1
            layer.cornerRadius = 5
            clipsToBounds = true
            layer.borderColor = isInAlertMode ? alertBorderColor.cgColor : normalBorderColor.cgColor
        }
    }

}
