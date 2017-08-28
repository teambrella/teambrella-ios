//
//  ChatInputView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.06.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import UIKit

class ChatInputView: UIView, XIBInitable {
    var contentView: UIView!
    
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var textView: UITextView!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var placeholderLabel: UILabel!
    
    var onTextChange: (() -> Void)?
    
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
        textView.delegate = self
        placeholderLabel.text = ""
    }
}

extension ChatInputView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == nil || textView.text == "" {
            placeholderLabel.isHidden = false
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        onTextChange?()
        return true
    }
}
