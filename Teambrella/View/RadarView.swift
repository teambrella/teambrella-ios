//
//  RadarView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.06.17.

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
class RadarView: UIView {
    @IBInspectable var color: UIColor = .paleLilac
    @IBInspectable var segments: Int = 3
    @IBInspectable var diameter: CGFloat = 136
    @IBInspectable var startAngle: CGFloat = 0
    @IBInspectable var endAngle: CGFloat = 180
    @IBInspectable var centerX: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var centerY: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var startWidth: CGFloat = 20
    @IBInspectable var coefficient: CGFloat = 1.3
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard segments > 0 else { return }

        let center: CGPoint!
        //size = (bounds.midX - diameter / 2) / CGFloat(segments)
        center = CGPoint(x: centerX + bounds.midX, y: centerY + bounds.maxY)
        //center = CGPoint(x: bounds.midX, y: bounds.maxY)
        var size = startWidth
        var x = (diameter + size) / 2
        
        for i in 0..<segments {
            context.setStrokeColor(colorFor(segment: i).cgColor)
            context.setLineWidth(size)
            context.addArc(center: center,
                           radius: x,
                           startAngle: CGFloat.pi * 2 - radiansFrom(degrees: startAngle),
                           endAngle: CGFloat.pi * 2 - radiansFrom(degrees: endAngle), clockwise: true)
            context.strokePath()
            let oldSize = size
            size *= coefficient
            x += (size + oldSize) / 2
        }
    }
    
    private func colorFor(segment: Int) -> UIColor {
        guard let background = backgroundColor else { return color }
        
        let segments = CGFloat(self.segments)
        let segment = CGFloat(segment + 1)
        guard segments > 0 && segment > 0 else { return color }
        
        let r = (background.redValue - color.redValue) / segments * segment
        let g = (background.greenValue - color.greenValue) / segments * segment
        let b = (background.blueValue - color.blueValue) / segments * segment
        let a = (background.alphaValue - color.alphaValue) / segments * segment
        
        return UIColor(red: background.redValue - r,
                       green: background.greenValue - g,
                       blue: background.blueValue - b,
                       alpha: background.alphaValue - a)
    }
    
}
