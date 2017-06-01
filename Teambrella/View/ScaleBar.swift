//
//  ScaleBar.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
    
    @IBInspectable
    var leftText: String? {
        get { return leftLabel.text }
        set {
            leftLabel.text = newValue
            setNeedsLayout()
        }
    }
    @IBInspectable
    var rightText: String? {
        get { return rightLabel.text }
        set {
            rightLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    var value: CGFloat = 0 {
        didSet {
            if value < 0 { value = 0 }
            if value > 1 { value = 1 }
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var lineWidth: CGFloat = 4
    @IBInspectable
    var valueColor: UIColor = .lightBlue
    @IBInspectable
    var lineColor: UIColor = .paleGray
    
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
        
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(1)
        context.setLineCap(.butt)
        context.move(to: CGPoint(x: 0, y: bounds.height - lineWidth / 2))
        context.addLine(to: CGPoint(x: bounds.width, y: bounds.height - lineWidth / 2))
        context.strokePath()
        
        context.setStrokeColor(valueColor.cgColor)
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        context.move(to: CGPoint(x: lineWidth / 2, y: bounds.height - lineWidth / 2))
        context.addLine(to: CGPoint(x: bounds.width * value, y: bounds.height - lineWidth / 2))
        context.strokePath()
    }
    
}
