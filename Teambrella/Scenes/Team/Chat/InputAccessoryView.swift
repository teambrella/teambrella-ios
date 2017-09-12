//
//  InputAccessoryView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 12.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import SnapKit
import UIKit

class InputAccessoryView: UIView {
    
    lazy var textView: UITextView = {
       let textView = UITextView()
        textView.layer.cornerRadius = 5
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
        label.textColor = .paleGray
        label.text = "Your message here"
        self.addSubview(label)
        return label
    }()
    
    var maxHeight: CGFloat = 70
    
     var onTextChange: (() -> Void)?
    
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
        backgroundColor = .lightBlueGray
        autoresizingMask = [.flexibleHeight]
        setupConstraints()
    }
    
    func setupConstraints() {
        leftButton.snp.makeConstraints { make in
            make.size.equalTo(44)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
        }
        rightButton.snp.makeConstraints { make in
            make.size.equalTo(44)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        textView.snp.makeConstraints { make in
            make.left.equalTo(leftButton.snp.right)
            make.right.equalTo(rightButton.snp.left)
            make.bottom.equalToSuperview().inset(7)
            make.top.greaterThanOrEqualToSuperview().offset(3)
            make.height.lessThanOrEqualTo(maxHeight)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.center.equalTo(textView)
            make.size.lessThanOrEqualTo(textView)
        }
        
        snp.makeConstraints { make in
            make.height.lessThanOrEqualTo(maxHeight + 10)
        }
    }
    
    func adjustHeight() {
        invalidateIntrinsicContentSize()
    }
    
}

// MARK: UITextViewDelegate
extension InputAccessoryView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
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
