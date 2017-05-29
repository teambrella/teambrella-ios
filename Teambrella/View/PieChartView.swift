//
//  ChartView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

@IBDesignable
class PieChartView: UIView {
    @IBInspectable
    var startAngle: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var endAngle: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var lineWidth: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var lineColor: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var pieColor: UIColor = .lightGold {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var pieceAlpha: CGFloat = 0.4 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let startAngle = compass(degrees: self.startAngle)
        let endAngle = compass(degrees: self.endAngle)
        
        let radius = min(frame.size.width, frame.size.height) * 0.5
        let viewCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        
        ctx.setFillColor(pieColor.withAlphaComponent(pieceAlpha).cgColor)
        ctx.move(to: viewCenter)
        // clockwise: false on iPhone will draw clockwise (because of inverted coordinates space)
        ctx.addArc(center: viewCenter,
                   radius: radius,
                   startAngle: startAngle,
                   endAngle: endAngle,
                   clockwise: false)
        ctx.fillPath()
        
        ctx.move(to: viewCenter)
        ctx.setFillColor(pieColor.cgColor)
        ctx.addArc(center: viewCenter,
                   radius: radius,
                   startAngle: endAngle,
                   endAngle: startAngle,
                   clockwise: false)
        ctx.fillPath()
        
        let circle = Circle(radius: radius, center: viewCenter)
        ctx.setStrokeColor(lineColor.cgColor)
        ctx.move(to: circle.circumferencePoint(radians: startAngle))
        ctx.addLine(to: viewCenter)
        ctx.addLine(to: circle.circumferencePoint(radians: endAngle))
        ctx.setLineWidth(lineWidth)
        ctx.strokePath()
        
    }
    
}
