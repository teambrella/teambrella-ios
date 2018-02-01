//
//  ScaleBar.swift
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
class ScaleBar: UIView {
    lazy var leftLabel: Label = {
        let label = InfoLabel(frame: self.bounds)
        self.addSubview(label)
        return label
    }()
    
    lazy var rightLabel: Label = {
        let label = InfoLabel(frame: self.bounds)
        self.addSubview(label)
        return label
    }()
    
    @IBInspectable var leftText: String? {
        get { return leftLabel.text }
        set {
            leftLabel.text = newValue
            setNeedsLayout()
        }
    }
    @IBInspectable var rightText: String? {
        get { return rightLabel.text }
        set {
            rightLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    @IBInspectable var value: CGFloat = 0 {
        didSet {
            if value < 0 { value = 0 }
            if value > 1 { value = 1 }
            setNeedsDisplay()
        }
    }
    @IBInspectable var lineWidth: CGFloat = 4
    @IBInspectable var valueColor: UIColor = .lightBlue
    @IBInspectable var lineColor: UIColor = .paleGray
    @IBInspectable var isLineHidden: Bool = false {
        didSet {
            if oldValue != isLineHidden {
                setNeedsDisplay()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        leftLabel.sizeToFit()
        rightLabel.sizeToFit()
        leftLabel.frame.origin = CGPoint(x: 0, y: 0)
        rightLabel.frame.origin = CGPoint(x: bounds.width - rightLabel.frame.width, y: 0)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard isLineHidden == false else { return }
        
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(1)
        context.setLineCap(.butt)
        context.move(to: CGPoint(x: 0, y: bounds.height - lineWidth / 2))
        context.addLine(to: CGPoint(x: bounds.width, y: bounds.height - lineWidth / 2))
        context.strokePath()
        
        context.setStrokeColor(valueColor.cgColor)
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        let startPoint = CGPoint(x: lineWidth / 2, y: bounds.height - lineWidth / 2)
        context.move(to: startPoint)
        var endPoint = CGPoint(x: (bounds.width - lineWidth / 2) * value, y: bounds.height - lineWidth / 2)
        if endPoint.x < startPoint.x { endPoint.x = startPoint.x + 1 }
        context.addLine(to: endPoint)
        context.strokePath()
    }
    
    func autoSet(value: Double) {
        self.value = CGFloat(value)
        leftText = "\(Int(self.value * 100))"
    }
    
}
