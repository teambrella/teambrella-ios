//
//  NumberBar.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

@IBDesignable
class NumberBar: UIView, XIBInitable {
    
    var contentView: UIView!
    
    @IBInspectable
    var count: Int = 2 {
        didSet {
            populateNumberViews()
        }
    }
    @IBInspectable
    var isBottomLineVisible: Bool = false
    @IBInspectable
    var lineColor: UIColor = .paleGray {
        didSet { drawingView.redraw(master: self) }
    }
    @IBInspectable
    var stackHeight: CGFloat {
        get { return stackViewHeight.constant }
        set { stackViewHeight.constant = newValue }
    }
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var stackViewHeight: NSLayoutConstraint!
    @IBOutlet var drawingView: NumberBarDrawingView!
    
    var left: NumberView? {
        return stackView.arrangedSubviews.first as? NumberView
    }
    
    var right: NumberView? {
        return stackView.arrangedSubviews.last as? NumberView
    }
    
    var middle: NumberView? {
        guard stackView.arrangedSubviews.count % 2 != 0 else { return nil }
        
        return stackView.arrangedSubviews[stackView.arrangedSubviews.count / 2] as? NumberView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    private func populateNumberViews() {
        while stackView.arrangedSubviews.count > count {
            stackView.arrangedSubviews.last?.removeFromSuperview()
        }
        while stackView.arrangedSubviews.count < count {
            let numberView = NumberView(frame: bounds)
            stackView.addArrangedSubview(numberView)
        }
        drawingView.redraw(master: self)
    }
    
    }

class NumberBarDrawingView: UIView {
    weak var master: NumberBar?
    
    func redraw(master: NumberBar) {
        self.master = master
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext(),
            let master = master else { return }
        
        context.setStrokeColor(master.lineColor.cgColor)
        context.setLineWidth(1)
        if master.isBottomLineVisible {
            context.move(to: CGPoint(x: 0, y: bounds.maxY))
            context.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
            context.strokePath()
        }
         let views = master.stackView.arrangedSubviews
           guard views.count > 1 else { return }
        
        for i in 0..<views.count - 1 {
            let subview = views[i]
            context.move(to: CGPoint(x: subview.frame.maxX, y: master.stackView.frame.minY))
            context.addLine(to: CGPoint(x: subview.frame.maxX, y: master.stackView.frame.maxY))
            context.strokePath()
        }
    }
    
}

