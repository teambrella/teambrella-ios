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
        self.addSubview(button)
        button.addTarget(self, action: #selector(tapRightButton), for: .touchUpInside)
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

    lazy var continueJoiningLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.teambrella(size: 15)
        label.textColor = .bluishGray
        label.text = "Team.Chat.Input.continueJoining".localized
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(tapContinueJoining))
        recognizer.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(recognizer)
        self.addSubview(label)
        label.alpha = 0
        return label
    }()
    
    private var unreadCount : Int = 0

    lazy var goToDiscussionLabel: UIView = {
        let viewTop = UIView()
        return viewTop
    }()

    private func setupGoToDiscussionLabel() {
        let viewTop = goToDiscussionLabel
        for subview in viewTop.subviews {
            subview.removeFromSuperview()
        }
        
        let view = UILabel()
        
        let label = UILabel()
        label.font = UIFont.teambrella(size: 15)
        label.textColor = .bluishGray
        label.textAlignment = .left
        label.text = "Team.Chat.Input.goToDiscussion".localized
        label.sizeToFit()
        view.addSubview(label)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        if unreadCount > 0 {
            let badge = Label(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            badge.font = UIFont.teambrellaBold(size: 11)
            badge.textAlignment = .center
            badge.textInsets = UIEdgeInsets(top: 3, left: 4, bottom: 3, right: 4)
            badge.textColor = .white
            badge.layer.cornerRadius = 19.0 / 2
            badge.layer.masksToBounds = true
            badge.layer.borderColor = UIColor.clear.cgColor
            badge.layer.borderWidth = 1.5
            badge.backgroundColor = UIColor.tealish
            badge.frame = CGRect(x: 0, y: 0, width: 50, height: 24)
            badge.text = "\(unreadCount)"
            badge.sizeToFit()
            badge.frame.size.width = max(badge.frame.width, badge.frame.height)
            badge.center = CGPoint(x: label.frame.maxX + 16 + badge.frame.width / 2, y: label.center.y)
            
            view.frame = CGRect(x: 0, y: 0, width: badge.frame.maxX, height: label.frame.height)
            view.widthAnchor.constraint(equalToConstant: badge.frame.maxX).isActive = true
            view.heightAnchor.constraint(equalToConstant: badge.frame.maxY).isActive = true
            view.addSubview(badge)
        } else {
            view.widthAnchor.constraint(equalToConstant: label.frame.maxX).isActive = true
            view.heightAnchor.constraint(equalToConstant: label.frame.maxY).isActive = true
        }
        
        viewTop.addSubview(view)
        self.addSubview(viewTop)
        
        view.centerXAnchor.constraint(equalTo: viewTop.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: viewTop.centerYAnchor).isActive = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapGoToDiscussion))
        recognizer.numberOfTapsRequired = 1
        viewTop.isUserInteractionEnabled = true
        viewTop.addGestureRecognizer(recognizer)
        viewTop.alpha = 0
        
        viewTop.translatesAutoresizingMaskIntoConstraints = false
        viewTop.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        viewTop.centerYAnchor.constraint(equalTo: textView.centerYAnchor).isActive = true
        viewTop.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        viewTop.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    var maxHeight: CGFloat = 70
    
    var onTextChange: (() -> Void)?
    var onTextChanged: ((String) -> Void)?
    var onBeginEdit: (() -> Void)?
    var onTapSend: (() -> Void)?
    var onTapPhoto: (() -> Void)?
    var onEndEditing: ((String?) -> Void)?
    var onTapContinueJoining: (() -> Void)?
    var onTapGoToDiscussion: (() -> Void)?

    var isEmpty: Bool { return textView.text == nil || textView.text == "" }

    private var onTapRightButton: (() -> Void)?

    var textLeftConstraint: NSLayoutConstraint!
    
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
        textLeftConstraint = textView.leftAnchor.constraint(equalTo: leftButton.rightAnchor)
        textLeftConstraint.isActive = true
        textView.rightAnchor.constraint(equalTo: rightButton.leftAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        textView.heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight).isActive = true
        
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.centerXAnchor.constraint(equalTo: textView.centerXAnchor).isActive = true
        placeholderLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor).isActive = true
        placeholderLabel.widthAnchor.constraint(lessThanOrEqualTo: textView.widthAnchor).isActive = true
        placeholderLabel.heightAnchor.constraint(lessThanOrEqualTo: textView.heightAnchor).isActive = true
        
        continueJoiningLabel.translatesAutoresizingMaskIntoConstraints = false
        continueJoiningLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        continueJoiningLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor).isActive = true
        continueJoiningLabel.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor).isActive = true
        continueJoiningLabel.heightAnchor.constraint(lessThanOrEqualTo: textView.heightAnchor).isActive = true

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

    func showContinueJoining() {
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseOut], animations: {
            self.leftButton.alpha = 0
            self.rightButton.alpha = 0
            self.textView.alpha = 0
            self.placeholderLabel.alpha = 0
            self.continueJoiningLabel.alpha = 1
        }) { finished in
            
        }
//        leftButton.isHidden = true
//        rightButton.isHidden = true
//        textView.isHidden = true
//        placeholderLabel.isHidden = true
//        continueJoiningLabel.isHidden = false
    }

    func showGoToDiscussion(unreadCount: Int) {
        guard (self.continueJoiningLabel.alpha == 0) else {return}
        self.unreadCount = unreadCount
        self.setupGoToDiscussionLabel()
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.leftButton.alpha = 0
            self.rightButton.alpha = 0
            self.textView.alpha = 0
            self.placeholderLabel.alpha = 0
            self.goToDiscussionLabel.alpha = 1
        }) { finished in
            
        }
    }

    func hideGoToDiscussion() {
        guard (self.goToDiscussionLabel.alpha > 0) else {return}
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.leftButton.alpha = 1
            self.rightButton.alpha = 1
            self.textView.alpha = 1
            self.placeholderLabel.alpha = 1
            self.goToDiscussionLabel.alpha = 0
        }) { finished in
            
        }
        //        leftButton.isHidden = true
        //        rightButton.isHidden = true
        //        textView.isHidden = true
        //        placeholderLabel.isHidden = true
        //        continueJoiningLabel.isHidden = false
    }

    
    func showLeftButton() {
        leftButton.isHidden = false
        textLeftConstraint.constant = 0
    }

    func hideLeftButton() {
        leftButton.isHidden = true
        textLeftConstraint.constant = -leftButton.frame.width + 8
    }

    func showRightButtonSend() {
        rightButton.setImage(#imageLiteral(resourceName: "send"), for: .normal)
        onTapRightButton = onTapSend
    }

    func showRightButtonPhoto() {
        rightButton.setImage(#imageLiteral(resourceName: "camera"), for: .normal)
        onTapRightButton = onTapPhoto
    }

    @objc
    private func tapRightButton() {
        onTapRightButton?()
    }
    
    @objc
    private func tapContinueJoining() {
        onTapContinueJoining?()
    }

    @objc
    private func tapGoToDiscussion() {
        onTapGoToDiscussion?()
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
        onTextChanged?(textView.text ?? "")
    }
 
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == nil || textView.text == "" {
            placeholderLabel.isHidden = false
        }
        onEndEditing?(textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        onTextChange?()
        return true
    }
}
