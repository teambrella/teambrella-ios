//
//  Label.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 27.05.17.

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
    
}
