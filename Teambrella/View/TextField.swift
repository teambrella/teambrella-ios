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
    private lazy var editDecorator = { EditDecorator(view: self) }()
    var isInEditMode: Bool {
        get { return editDecorator.isInEditMode }
        set { editDecorator.isInEditMode = newValue }
    }
    
}

class TextView: UITextView {
    private lazy var alertDecorator = { AlertDecorator(view: self) }()
    var isInAlertMode: Bool {
        get { return alertDecorator.isInAlertMode }
        set { alertDecorator.isInAlertMode = newValue }
    }
    private lazy var editDecorator = { EditDecorator(view: self) }()
    var isInEditMode: Bool {
        get { return editDecorator.isInEditMode }
        set { editDecorator.isInEditMode = newValue }
    }
}

class AlertDecorator {
    weak var view: UIView?
    var alertBorderColor: UIColor = .red
    var normalBorderColor: UIColor = .cloudyBlue
    
    var isInAlertMode: Bool {
        didSet {
            guard let view = view else { return }
            
            view.layer.borderWidth = 1
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

class EditDecorator {
    weak var view: UIView?
    var normalBorderColor: UIColor = .cloudyBlue
    var editBorderColor: UIColor = .bluishGray
    
    var isInEditMode: Bool {
        didSet {
            guard let view = view else { return }
            
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 5
            view.clipsToBounds = true
            view.layer.borderColor = isInEditMode ? editBorderColor.cgColor : normalBorderColor.cgColor
        }
    }
    
    init(view: UIView) {
        self.view = view
        self.isInEditMode = false
    }
    
}
