//
//  ChatTextCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import SwiftSoup

class ChatTextCell: UICollectionViewCell {
    struct Constant {
        static let tailWidth: CGFloat = 10
        static let tailHeight: CGFloat = 7
        static let cloudCornerRadius: CGFloat = 5
        static let avatarWidth: CGFloat = 15 * UIScreen.main.nativeScale
        static let avatarContainerInset: CGFloat = 5
        static let avatarCloudInset: CGFloat = 5
    }
    
    lazy var avatarView: RoundImageView = {
        let imageView = RoundImageView()
        self.contentView.addSubview(imageView)
        return imageView
    }()
    
    lazy var leftLabel: Label = {
        let label = Label()
        self.contentView.addSubview(label)
        return label
    }()
    
    lazy var rightLabel: Label = {
        let label = Label()
        self.contentView.addSubview(label)
        return label
    }()
    
    lazy var bottomLabel: Label = {
        let label = Label()
        self.contentView.addSubview(label)
        return label
    }()
    
    var views: [UIView] = []
    
    var width: CGFloat {
        return bounds.width
    }
    
    var cloudStartPoint: CGPoint {
        if isMy {
            return CGPoint(x: width - cloudInsetX, y: cloudHeight)
        } else {
            return CGPoint(x: cloudInsetX, y: cloudHeight)
        }
    }
    
    var cloudHeight: CGFloat {
        return 80
    }
    
    var cloudWidth: CGFloat {
        return 250
    }
    
    var cloudInsetX: CGFloat {
        return Constant.avatarContainerInset + Constant.avatarWidth + Constant.avatarCloudInset
    }
    
    var cloudBodyMinX: CGFloat {
        if isMy {
            return cloudStartPoint.x - Constant.tailWidth - cloudWidth
        } else {
            return cloudStartPoint.x + Constant.tailWidth
        }
    }
    var cloudBodyMaxX: CGFloat {
        if isMy {
            return cloudStartPoint.x - Constant.tailWidth
        } else {
            return cloudStartPoint.x + Constant.tailWidth + cloudWidth
        }
    }
    
    var isMy: Bool = false {
        didSet {
            let x = isMy ? width - Constant.avatarContainerInset - Constant.avatarWidth : Constant.avatarContainerInset
            avatarView.frame = CGRect(x: x,
                                      y: cloudHeight - Constant.avatarWidth,
                                      width: Constant.avatarWidth,
                                      height: Constant.avatarWidth)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor = .clear
    }
    
    func populate(with model: ChatEntity) {
        
    }
    
    // swiftlint:disable:next function_body_length
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if isMy {
            //
            //
            //
            //             \
            var pen: CGPoint = cloudStartPoint
            context.move(to: pen)
            pen.x -= Constant.tailWidth
            pen.y -= Constant.tailHeight
            context.addLine(to: pen)
            
            //
            //            |
            //            |
            //             \
            pen.y = Constant.cloudCornerRadius
            context.addLine(to: pen)
            
            //           \
            //            |
            //            |
            //             \
            var controlP = CGPoint(x: pen.x, y: 0)
            pen.x -= Constant.cloudCornerRadius
            pen.y = 0
            context.addQuadCurve(to: pen, control:controlP)
            
            //  _________
            //           \
            //            |
            //            |
            //             \
            pen.x = cloudBodyMinX + Constant.cloudCornerRadius
            context.addLine(to: pen)
            
            //  _________
            // /         \
            //            |
            //            |
            //             \
            pen.x = cloudBodyMinX
            pen.y = Constant.cloudCornerRadius
            controlP = CGPoint(x: cloudBodyMinX, y: 0)
            context.addQuadCurve(to: pen,
                                 control: controlP)
            
            //  _________
            // /         \
            // |          |
            // |          |
            //             \
            pen.y = cloudHeight - Constant.cloudCornerRadius
            context.addLine(to: pen)
            
            //  _________
            // /         \
            // |          |
            // |          |
            // \           \
            pen.x += Constant.cloudCornerRadius
            pen.y = cloudHeight
            controlP = CGPoint(x: cloudBodyMinX, y: cloudHeight)
            context.addQuadCurve(to: pen,
                                 control: controlP)
            
            //  _________
            // /         \
            // |          |
            // |          |
            // \___________\
            context.closePath()
        } else {
            // /
            var pen: CGPoint = cloudStartPoint
            context.move(to: pen)
            pen.x += Constant.tailWidth
            pen.y -= Constant.tailHeight
            context.addLine(to: pen)
            
            //  |
            //  |
            // /
            pen.y = Constant.cloudCornerRadius
            context.addLine(to: pen)
            
            //   /
            //  |
            //  |
            // /
            var controlP = CGPoint(x: pen.x, y: 0)
            pen.x += Constant.cloudCornerRadius
            pen.y = 0
            context.addQuadCurve(to: pen, control:controlP)
            
            //    ________
            //   /
            //  |
            //  |
            // /
            pen.x = cloudBodyMaxX - Constant.cloudCornerRadius
            context.addLine(to: pen)
            
            //    ________
            //   /        \
            //  |
            //  |
            // /
            pen.x = cloudBodyMaxX
            pen.y = Constant.cloudCornerRadius
            controlP = CGPoint(x: cloudBodyMaxX, y: 0)
            context.addQuadCurve(to: pen,
                                 control: controlP)
            
            //    ________
            //   /        \
            //  |          |
            //  |          |
            // /
            pen.y = cloudHeight - Constant.cloudCornerRadius
            context.addLine(to: pen)
            
            //    ________
            //   /        \
            //  |          |
            //  |          |
            // /          /
            pen.x -= Constant.cloudCornerRadius
            pen.y = cloudHeight
            controlP = CGPoint(x: cloudBodyMaxX, y: cloudHeight)
            context.addQuadCurve(to: pen,
                                 control: controlP)
            
            //    ________
            //   /        \
            //  |          |
            //  |          |
            // /__________/
            context.closePath()
        }
        context.setStrokeColor(UIColor.lightBlueGray.cgColor)
        context.setLineWidth(1)
        context.setFillColor(UIColor.veryLightBlue.cgColor)
        context.drawPath(using: .fillStroke)
    }
    
}
