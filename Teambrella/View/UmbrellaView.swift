//
//  UmbrellaView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.05.17.

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

class UmbrellaView: UIView {
var fillLayer: CAShapeLayer?
    var startCurveCoeff: CGFloat = 0.4
    var fillColor: UIColor = #colorLiteral(red: 0.9725490196, green: 0.9803921569, blue: 0.9921568627, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        self.fillLayer?.removeFromSuperlayer()
        let path = UIBezierPath(rect: bounds)
        let wdt = bounds.width
        let hgt = bounds.height
        let y = hgt * startCurveCoeff
        path.move(to: CGPoint(x: 0.0, y: 0))
        path.addLine(to: CGPoint(x: 0.0, y: y))
        path.addQuadCurve(to: CGPoint(x: wdt, y: y), controlPoint: CGPoint(x: wdt / 2, y: 0))
        path.addLine(to: CGPoint(x: wdt, y: 0))
        path.close()
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = fillColor.cgColor
        layer.addSublayer(fillLayer)
        self.fillLayer = fillLayer
    }
    
    override func layoutSubviews() {
        setup()
        super.layoutSubviews()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
