//
//  Label.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 27.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

@IBDesignable
class Label: UILabel {
    enum LabelType: String {
        case custom
        
        case header
        case subheader
        
        case amount
        case walletAmount
        case currencySmall
        case currencyNormal
        case badge
        
        case info
        case infoHelp
        
        case itemName
        case itemValue
        
        case title
        case thinStatusSubtitle
        case statusSubtitle
        case blockHeader
        
        case messageTitle
        case messageText
        case chatText
    }
    
    @IBInspectable
    var topInset: CGFloat {
        get { return textInsets.top }
        set { textInsets.top = newValue }
    }
    @IBInspectable
    var leftInset: CGFloat {
        get { return textInsets.left }
        set { textInsets.left = newValue }
    }
    @IBInspectable
    var bottomInset: CGFloat {
        get { return textInsets.bottom }
        set { textInsets.bottom = newValue }
    }
    @IBInspectable
    var rightInset: CGFloat {
        get { return textInsets.right }
        set { textInsets.right = newValue }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            if newValue != 0 {
                layer.masksToBounds = true
            }
            layer.cornerRadius = newValue
        }
    }
    
    // Xcode doesn't allow to use enumerations in storyboard so this is a temporary workaround
    @IBInspectable
    var labelType: String = "" {
        didSet {
            type = LabelType(rawValue: labelType) ?? .custom
        }
    }
    
    var type: LabelType = .custom {
        didSet {
            setupStyle()
        }
    }
    
    var textInsets: UIEdgeInsets = .zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    dynamic override var text: String? {
        get {
            return super.text
        }
        set {
            super.text = isCapitalized ? newValue?.capitalized : newValue
        }
    }
    
    var isCapitalized: Bool = false

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = UIEdgeInsetsInsetRect(bounds, textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, textInsets))
    }
    
    private func setupStyle() {
        guard type != .custom else { return }
        
        font = font(for: type)
        textColor = color(for: type)
        modification(for: type)
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    private func font(for type: LabelType) -> UIFont {
        switch type {
        case .info, .infoHelp:
            return UIFont.boldSystemFont(ofSize: 10)
        case .itemName, .itemValue:
            return UIFont.systemFont(ofSize: 15)
        case .amount, .currencyNormal:
            return UIFont.boldSystemFont(ofSize: 23)
        case .currencySmall:
            return UIFont.boldSystemFont(ofSize: 9)
        case .badge:
            return UIFont.systemFont(ofSize: 9)
        case .thinStatusSubtitle:
            return UIFont.systemFont(ofSize: 10)
        case .statusSubtitle:
            return UIFont.boldSystemFont(ofSize: 12)
        case .messageText:
            return UIFont.systemFont(ofSize: 12)
        case .subheader:
            return UIFont.boldSystemFont(ofSize: 13)
        case .blockHeader:
            return UIFont.boldSystemFont(ofSize: 14)
        case .chatText:
            return UIFont.systemFont(ofSize: 14)
        case .messageTitle:
            return UIFont.boldSystemFont(ofSize: 15)
        case .title:
            return UIFont.boldSystemFont(ofSize: 20)
        case .header:
            return UIFont.boldSystemFont(ofSize: 25)
        case .walletAmount:
            return UIFont.boldSystemFont(ofSize: 88)
        
        case .custom:
            return UIFont()
        }
    }
    
    private func color(for type: LabelType) -> UIColor {
        switch type {
        case .info, .infoHelp, .thinStatusSubtitle, .statusSubtitle:
            return UIColor.blueyGray
        case .messageText:
            return UIColor.bluishGray
        case .chatText, .itemName, .itemValue, .title:
            return UIColor.charcoalGray
        case .messageTitle, .amount, .walletAmount:
            return UIColor.dark
        case .currencySmall, .currencyNormal, .blockHeader:
            return UIColor.darkSkyBlue
        case .badge, .header:
            return UIColor.white
        case .subheader:
            return UIColor.white50
            
        case .custom:
            return UIColor()
        }
    }
    
    private func modification(for type: LabelType) {
        switch type {
        case .badge:
            cornerRadius = 2
            backgroundColor = UIColor.lightBlue
        case .blockHeader, .info:
            isCapitalized = true
        default:
            break
        }
    }
    
}
