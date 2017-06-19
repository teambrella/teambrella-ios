//
//  ChatInputView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

class ChatInputView: UIView, XIBInitable {
    var contentView: UIView!
    
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var textView: UITextView!
    @IBOutlet var rightButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        setup()
    }
    
    private func setup() {
        textView.layer.cornerRadius = 5
        textView.layer.borderColor = UIColor.cloudyBlue.cgColor
        textView.layer.borderWidth = 1
    }
}
