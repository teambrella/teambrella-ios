//
//  RoundedCornersView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 04.07.17.

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
class RoundedCornersView: GradientView {
    @IBInspectable var topLeft: Bool = false {
        didSet {
            if topLeft == true {
                roundingCorners.insert(.topLeft)
            } else {
                roundingCorners.remove(.topLeft)
            }
        }
    }
    @IBInspectable var topRight: Bool = false {
        didSet {
            if topRight == true {
                roundingCorners.insert(.topRight)
            } else {
                roundingCorners.remove(.topRight)
            }
        }
    }
    @IBInspectable var bottomLeft: Bool = false {
        didSet {
            if bottomLeft == true {
                roundingCorners.insert(.bottomLeft)
            } else {
                roundingCorners.remove(.bottomLeft)
            }
        }
    }
    @IBInspectable var bottomRight: Bool = false {
        didSet {
            if bottomRight == true {
                roundingCorners.insert(.bottomRight)
            } else {
                roundingCorners.remove(.bottomRight)
            }
        }
    }
    
    var roundingCorners: UIRectCorner = []
    
    @IBInspectable var cornerRadius: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        layer.mask = maskLayer
    }
    
}
