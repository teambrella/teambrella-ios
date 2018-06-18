//
//  EggView.swift
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
class EggView: UIView {
    @IBInspectable var eggWidth: CGFloat  = 50
    @IBInspectable var eggHeight: CGFloat = 80
    @IBInspectable var glowWidth: CGFloat = 5
    @IBInspectable var color: UIColor     = .blue
    @IBInspectable var glowAlpha: CGFloat = 0.3
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: bounds.midX, y: bounds.maxY - eggHeight))
        bezierPath.addCurve(to: CGPoint(x: bounds.midX,
                                        y: bounds.maxY),
                            controlPoint1: CGPoint(x: bounds.midX - eggWidth / 2,
                                                   y: bounds.maxY - eggHeight * 0.5) ,
                            controlPoint2: CGPoint(x: bounds.midX - eggWidth / 2,
                                                   y: bounds.maxY - (eggHeight - eggWidth)))
        bezierPath.addCurve(to: CGPoint(x: bounds.midX,
                                        y: bounds.maxY - eggHeight),
                            controlPoint1: CGPoint(x: bounds.midX + eggWidth / 2,
                                                   y: bounds.maxY - (eggHeight - eggWidth)),
                            controlPoint2: CGPoint(x: bounds.midX + eggWidth / 2,
                                                   y: bounds.maxY - eggHeight * 0.5))
        bezierPath.close()
        
        color.setFill()
        color.withAlphaComponent(glowAlpha).setStroke()
        bezierPath.lineWidth = glowWidth
        bezierPath.stroke()
        bezierPath.fill()
    }
    
}
