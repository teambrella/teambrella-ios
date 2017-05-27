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
    
    var textInsets: UIEdgeInsets = .zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

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
}
