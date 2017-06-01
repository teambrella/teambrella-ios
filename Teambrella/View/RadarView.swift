//
//  RadarView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

@IBDesignable
class RadarView: UIView {
    @IBInspectable
    var color: UIColor = .paleLilac
    @IBInspectable
    var segments: Int = 3
    @IBInspectable
    var diameter: CGFloat = 136
    var coefficient: CGFloat = 1.3
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard segments > 0 else { return }
        
        var wdt = (bounds.midX - diameter / 2) / CGFloat(segments)
        var x = (diameter + wdt) / 2
        
        for i in 0..<segments {
            context.setStrokeColor(colorFor(segment: i).cgColor)
            context.setLineWidth(wdt)
            context.addArc(center: CGPoint(x: bounds.midX, y: bounds.maxY),
                           radius: x, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
            context.strokePath()
            x += wdt
            wdt *= coefficient
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
