//
//  InputAccessoryView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 12.09.17.
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
//

import UIKit

class InputAccessoryView: UIView {
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.teambrella(size: 14)
        textView.layer.cornerRadius = 3
        textView.layer.borderColor = UIColor.cloudyBlue.cgColor
        textView.layer.borderWidth = 1
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = true
        self.addSubview(textView)
        return textView
    }()
    
    lazy var leftButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "attachment"), for: .normal)
        self.addSubview(button)
        return button
    }()
    
    lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "send"), for: .normal)
        self.addSubview(button)
        return button
    }()
    
    lazy var placeholderLabel: Label = {
        let label = Label()
        label.font = UIFont.teambrella(size: 14)
        label.textColor = .cloudyBlue
        label.text = "Team.Chat.Input.yourMessageHere".localized
        self.addSubview(label)
        return label
    }()
    
    var maxHeight: CGFloat = 70
    
    var onTextChange: (() -> Void)?
    var onBeginEdit: (() -> Void)?
    
    override var intrinsicContentSize: CGSize {
        let textSize = self.textView.sizeThatFits(CGSize(width: self.textView.bounds.width,
                                                         height: CGFloat.greatestFiniteMagnitude))
        textView.isScrollEnabled = textSize.height > maxHeight
        return CGSize(width: self.bounds.width, height: textSize.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .paleGrayFour
        autoresizingMask = [.flexibleHeight]
        setupConstraints()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if let window = self.window {
                self.bottomAnchor
                    .constraint(lessThanOrEqualToSystemSpacingBelow: window.safeAreaLayoutGuide.bottomAnchor,
                                                                   multiplier: 1.0)
                    .isActive = true
            }
        }
    }
    
    func setupConstraints() {
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        leftButton.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        leftButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        leftButton.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor).isActive = true
        
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        rightButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        rightButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        rightButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        rightButton.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor).isActive = true
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leftAnchor.constraint(equalTo: leftButton.rightAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: rightButton.leftAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        textView.heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight).isActive = true
        
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.centerXAnchor.constraint(equalTo: textView.centerXAnchor).isActive = true
        placeholderLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor).isActive = true
        placeholderLabel.widthAnchor.constraint(lessThanOrEqualTo: textView.widthAnchor).isActive = true
        placeholderLabel.heightAnchor.constraint(lessThanOrEqualTo: textView.heightAnchor).isActive = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight + 10).isActive = true
    }
    
    func adjustHeight() {
        invalidateIntrinsicContentSize()
    }

    func allowInput(_ allow: Bool) {
        leftButton.isEnabled = allow
        rightButton.isEnabled = allow
        textView.isUserInteractionEnabled = allow
    }
    
}

// MARK: UITextViewDelegate
extension InputAccessoryView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
        onBeginEdit?()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        invalidateIntrinsicContentSize()
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
