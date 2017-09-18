//
//  TextField.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class TextField: UITextField {
    private lazy var alertDecorator = { AlertDecorator(view: self) }()
    var isInAlertMode: Bool {
        get { return alertDecorator.isInAlertMode }
        set { alertDecorator.isInAlertMode = newValue }
    }
    
}

class TextView: UITextView {
    private lazy var alertDecorator = { AlertDecorator(view: self) }()
    var isInAlertMode: Bool {
        get { return alertDecorator.isInAlertMode }
        set { alertDecorator.isInAlertMode = newValue }
    }
    
}

class AlertDecorator {
    weak var view: UIView?
    var alertBorderColor: UIColor = .red
    var normalBorderColor: UIColor = .cloudyBlue
    
    var isInAlertMode: Bool {
        didSet {
            guard let view = view else { return }
            
            view.layer.borderWidth = 0.5
            view.layer.cornerRadius = 5
            view.clipsToBounds = true
            view.layer.borderColor = isInAlertMode ? alertBorderColor.cgColor : normalBorderColor.cgColor
        }
    }
    
    init(view: UIView) {
        self.view = view
        self.isInAlertMode = false
    }
    
}
