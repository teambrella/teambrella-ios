//
//  ChatCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 19.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Kingfisher
import UIKit

@IBDesignable
class ChatCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var cloudView: UIView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var dateLabel: Label!
    
    @IBOutlet var cloudLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var cloudTrailingConstraint: NSLayoutConstraint!
    
    var isLeadingAlighed: Bool { return cloudLeadingConstraint.constant < 0.001 }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func align(offset: CGFloat, toLeading: Bool) {
        cloudLeadingConstraint.constant = toLeading ? 0 : offset
        cloudTrailingConstraint.constant = toLeading ? offset : 0
        setNeedsLayout()
    }
    
    func clearAll() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearAll()
    }
    
    func add(text: String) {
        let label = ChatTextLabel()
        label.numberOfLines = 0
        label.text = text
        stackView.addArrangedSubview(label)
    }
    
    func add(image: String) {
        let imageView = UIImageView()
        imageView.kf.setImage(with: URL(string: image))
        imageView.contentMode = .scaleAspectFill
        stackView.addArrangedSubview(imageView)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let tailW: CGFloat = 10
        let tailH: CGFloat = 7
        let radius: CGFloat = 5
        if isLeadingAlighed {
            context.move(to: CGPoint(x: 0, y: cloudView.frame.height))
            context.addLine(to: CGPoint(x: tailW, y: cloudView.frame.height - tailH))
            context.addLine(to: CGPoint(x: tailW, y: radius))
            context.addQuadCurve(to: CGPoint(x: tailW + radius, y: 0),
                                 control: CGPoint(x: tailW, y: 0))
            context.addLine(to: CGPoint(x: cloudView.frame.maxX - radius, y: 0))
            context.addQuadCurve(to: CGPoint(x: cloudView.frame.maxX, y: radius),
                                 control: CGPoint(x: cloudView.frame.maxX, y: 0))
            context.addLine(to: CGPoint(x: cloudView.frame.maxX, y: cloudView.frame.maxY - radius))
            context.addQuadCurve(to: CGPoint(x: cloudView.frame.maxX - radius, y: cloudView.frame.maxY),
                                 control: CGPoint(x: cloudView.frame.maxX, y: cloudView.frame.maxY))
            context.closePath()
        } else {
            context.move(to: CGPoint(x: cloudView.frame.maxX, y: cloudView.frame.height))
            context.addLine(to: CGPoint(x: cloudView.frame.maxX - tailW, y: cloudView.frame.height - tailH))
            context.addLine(to: CGPoint(x: cloudView.frame.maxX - tailW, y: radius))
            context.addQuadCurve(to: CGPoint(x: cloudView.frame.maxX - tailW - radius, y: 0),
                                 control: CGPoint(x: cloudView.frame.maxX - tailW, y: 0))
            context.addLine(to: CGPoint(x: cloudView.frame.minX + radius, y: 0))
            context.addQuadCurve(to: CGPoint(x: cloudView.frame.minX, y: radius),
                                 control: CGPoint(x: cloudView.frame.minX, y: 0))
            context.addLine(to: CGPoint(x: cloudView.frame.minX, y: cloudView.frame.maxY - radius))
            context.addQuadCurve(to: CGPoint(x: cloudView.frame.minX + radius, y: cloudView.frame.maxY),
                                 control: CGPoint(x: cloudView.frame.minX, y: cloudView.frame.maxY))
            context.closePath()
        }
        context.setStrokeColor(UIColor.lightBlueGray.cgColor)
        context.setLineWidth(1)
        context.setFillColor(UIColor.veryLightBlue.cgColor)
        context.drawPath(using: .fillStroke)
    }
    
    //    override var intrinsicContentSize: CGSize {
    //        var height: CGFloat = 0
    //
    //    }
    
}
