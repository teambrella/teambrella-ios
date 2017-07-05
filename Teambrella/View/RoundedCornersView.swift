//
//  RoundedCornersView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 04.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedCornersView: GradientView {
    @IBInspectable
    var topLeft: Bool = false {
        didSet {
            if topLeft == true {
                roundingCorners.insert(.topLeft)
            } else {
                roundingCorners.remove(.topLeft)
            }
        }
    }
    @IBInspectable
    var topRight: Bool = false {
        didSet {
            if topRight == true {
                roundingCorners.insert(.topRight)
            } else {
                roundingCorners.remove(.topRight)
            }
        }
    }
    @IBInspectable
    var bottomLeft: Bool = false {
        didSet {
            if bottomLeft == true {
                roundingCorners.insert(.bottomLeft)
            } else {
                roundingCorners.remove(.bottomLeft)
            }
        }
    }
    @IBInspectable
    var bottomRight: Bool = false {
        didSet {
            if bottomRight == true {
                roundingCorners.insert(.bottomRight)
            } else {
                roundingCorners.remove(.bottomRight)
            }
        }
    }
    
    var roundingCorners: UIRectCorner = []
    
    @IBInspectable
    var cornerRadius: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        layer.mask = maskLayer
    }
    
}
