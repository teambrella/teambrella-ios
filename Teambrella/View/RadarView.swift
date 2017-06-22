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
    @IBInspectable
    var rotated: Bool = false
    var coefficient: CGFloat = 1.3
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard segments > 0 else { return }
        
        let startAngle: CGFloat!
        let endAngle: CGFloat!
        var size: CGFloat = 0
        let center: CGPoint!
        if rotated {
            startAngle = CGFloat.pi
            endAngle = -CGFloat.pi
            size = (bounds.midY - diameter / 2) / CGFloat(segments)
            center = CGPoint(x: 0, y: bounds.midY)
        } else {
            startAngle = 0
            endAngle = CGFloat.pi
            size = (bounds.midX - diameter / 2) / CGFloat(segments)
            center = CGPoint(x: bounds.midX, y: bounds.maxY)
        }
        var x = (diameter + size) / 2
        
        for i in 0...segments + 1 {
            context.setStrokeColor(colorFor(segment: i).cgColor)
            context.setLineWidth(size)
            context.addArc(center: center,
                           radius: x, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            context.strokePath()
            x += size
            size *= coefficient
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
