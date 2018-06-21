//
//  SlashView.swift
//  Scroller
//
//  Created by Екатерина Рыжова on 29.06.17.
//  Copyright © 2017 Екатерина Рыжова. All rights reserved.
//

import UIKit

@IBDesignable
class SlashView: UIView {
    @IBInspectable var horizontallOffset: CGFloat = 8
    @IBInspectable var slashViewColor: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.setFillColor(slashViewColor.cgColor)
        ctx.move(to: CGPoint(x: bounds.midX + horizontallOffset, y: 0))
        ctx.addLine(to: CGPoint(x: bounds.midX - horizontallOffset, y: bounds.maxY))
        ctx.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        ctx.addLine(to: CGPoint(x: bounds.maxX, y: 0))
        ctx.closePath()
        ctx.fillPath()
    }
}
