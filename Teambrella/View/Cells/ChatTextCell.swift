//
//  ChatTextCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
//import SwiftSoup

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
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(self.avatarTap)
        self.contentView.addSubview(imageView)
        return imageView
    }()
    
    lazy var avatarTap: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        return gesture
    }()
    
    lazy var leftLabel: Label = {
        let label = Label()
        label.font = UIFont.teambrella(size: 12)
        label.textColor = .darkSkyBlue
        self.contentView.addSubview(label)
        return label
    }()
    
    lazy var rightLabel: Label = {
        let label = Label()
        label.font = UIFont.teambrella(size: 12)
        label.textColor = .bluishGray
        self.contentView.addSubview(label)
        return label
    }()
    
    lazy var bottomLabel: Label = {
        let label = Label()
        label.font = UIFont.teambrella(size: 10)
        label.textColor = .bluishGray
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
    
    var cloudHeight: CGFloat = 80
    var cloudWidth: CGFloat = 250
    var id: String = ""
    
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
            avatarView.isUserInteractionEnabled = !isMy
        }
    }
    
    var onTapImage: ((ChatTextCell, GalleryView) -> Void)?
    
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
            var pen: CGPoint = cloudStartPoint
            context.move(to: pen)
            pen.x -= Constant.tailWidth
            pen.y -= Constant.tailHeight
            context.addLine(to: pen)
            
            pen.y = Constant.cloudCornerRadius
            context.addLine(to: pen)
            
            var controlP = CGPoint(x: pen.x, y: 0)
            pen.x -= Constant.cloudCornerRadius
            pen.y = 0
            context.addQuadCurve(to: pen, control:controlP)
            
            pen.x = cloudBodyMinX + Constant.cloudCornerRadius
            context.addLine(to: pen)
            
            pen.x = cloudBodyMinX
            pen.y = Constant.cloudCornerRadius
            controlP = CGPoint(x: cloudBodyMinX, y: 0)
            context.addQuadCurve(to: pen,
                                 control: controlP)
            
            pen.y = cloudHeight - Constant.cloudCornerRadius
            context.addLine(to: pen)
            
            pen.x += Constant.cloudCornerRadius
            pen.y = cloudHeight
            controlP = CGPoint(x: cloudBodyMinX, y: cloudHeight)
            context.addQuadCurve(to: pen,
                                 control: controlP)
            
            context.closePath()
            
            context.setFillColor(UIColor.veryLightBlue.cgColor)
            context.setStrokeColor(UIColor.paleGray.cgColor)
        } else {
            var pen: CGPoint = cloudStartPoint
            context.move(to: pen)
            pen.x += Constant.tailWidth
            pen.y -= Constant.tailHeight
            context.addLine(to: pen)
            
            pen.y = Constant.cloudCornerRadius
            context.addLine(to: pen)
            
            var controlP = CGPoint(x: pen.x, y: 0)
            pen.x += Constant.cloudCornerRadius
            pen.y = 0
            context.addQuadCurve(to: pen, control:controlP)
            
            pen.x = cloudBodyMaxX - Constant.cloudCornerRadius
            context.addLine(to: pen)
            
            pen.x = cloudBodyMaxX
            pen.y = Constant.cloudCornerRadius
            controlP = CGPoint(x: cloudBodyMaxX, y: 0)
            context.addQuadCurve(to: pen,
                                 control: controlP)
            
            pen.y = cloudHeight - Constant.cloudCornerRadius
            context.addLine(to: pen)
            
            pen.x -= Constant.cloudCornerRadius
            pen.y = cloudHeight
            controlP = CGPoint(x: cloudBodyMaxX, y: cloudHeight)
            context.addQuadCurve(to: pen,
                                 control: controlP)
            
            context.closePath()
            
            context.setFillColor(UIColor.white.cgColor)
            context.setStrokeColor(UIColor.lightBlueGray.cgColor)
        }
        
        context.setLineWidth(1)
        context.drawPath(using: .fillStroke)
    }
    
    func prepare(with model: ChatCellModel, cloudWidth: CGFloat, cloudHeight: CGFloat) {
        guard let model = model as? ChatTextCellModel, model.id != id else { return }
        
        id = model.id
        isMy = model.isMy
        self.cloudWidth = cloudWidth
        self.cloudHeight = cloudHeight
        setNeedsDisplay()
        
        let baseFrame = CGRect(x: 0, y: 0, width: cloudWidth, height: 20)
        leftLabel.frame = baseFrame
        leftLabel.text = model.userName
        leftLabel.sizeToFit()
        leftLabel.center = CGPoint(x: cloudBodyMinX + leftLabel.frame.width / 2 + 8,
                                   y: leftLabel.frame.height / 2 + 8)
        
        rightLabel.frame = baseFrame
        rightLabel.text = String.formattedNumber(model.voteRate)
        rightLabel.sizeToFit()
        rightLabel.center = CGPoint(x: cloudBodyMaxX - rightLabel.frame.width / 2 - 8,
                                    y: rightLabel.frame.height / 2 + 8)
        bottomLabel.frame = baseFrame
        bottomLabel.text = DateProcessor().stringInterval(from: model.date)
        bottomLabel.sizeToFit()
        bottomLabel.center = CGPoint(x: cloudBodyMaxX - bottomLabel.frame.width / 2 - 8,
                                     y: cloudHeight - bottomLabel.frame.height / 2 - 8)
        
        avatarView.showAvatar(string: model.userAvatar)
        
        views.forEach { $0.removeFromSuperview() }
        views.removeAll()
        
        for (idx, fragment) in model.fragments.enumerated() {
            switch fragment {
            case let .text(text):
                let label: UILabel = createLabel(for: text, height: model.fragmentHeights[idx])
                contentView.addSubview(label)
                views.append(label)
            case let .image(urlString: urlString, aspect: _):
                let imageView = createGalleryView(for: urlString, height: model.fragmentHeights[idx])
                contentView.addSubview(imageView)
                views.append(imageView)
            }
        }
        
        let x = isMy ? width - Constant.avatarContainerInset - Constant.avatarWidth : Constant.avatarContainerInset
        avatarView.frame = CGRect(x: x,
                                  y: cloudHeight - Constant.avatarWidth,
                                  width: Constant.avatarWidth,
                                  height: Constant.avatarWidth)
    }
    
    func createLabel(for text: String, height: CGFloat) -> UILabel {
        let verticalOffset = views.last?.frame.maxY ?? leftLabel.frame.maxY + 8
        let label = UILabel(frame: CGRect(x: cloudBodyMinX + 8,
                                          y: verticalOffset,
                                          width: cloudWidth - 16,
                                          height: height))
        label.textColor = .charcoalGray
        label.text = text
        label.font = UIFont.teambrella(size: 14)
        label.numberOfLines = 0
        return label
    }
    
    func createGalleryView(for urlString: String, height: CGFloat) -> GalleryView {
        let verticalOffset = views.last?.frame.maxY ?? leftLabel.frame.maxY + 8
        let separator: CGFloat = 2.0
        
        let imageView = GalleryView(frame: CGRect(x: cloudBodyMinX + separator,
                                                  y: verticalOffset + separator,
                                                  width: cloudWidth - separator * 2,
                                                  height: height))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        print("string|: \(urlString)")
        imageView.present(imageString: urlString)
        imageView.onTap = { [weak self] sender in
            self?.onTap(galleryView: sender)
        }
        return imageView
    }
    
    func onTap(galleryView: GalleryView) {
        onTapImage?(self, galleryView)
    }
    
}
