//
//  ChatTextCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.08.17.
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
//

import UIKit

class ChatTextCell: UICollectionViewCell {
    struct Constant {
        static let tailWidth: CGFloat = 8
        static let tailHeight: CGFloat = 8
        static let tailSoftening: CGFloat = 3
        static let tailCornerRadius: CGFloat = 1
        static let cloudCornerRadius: CGFloat = 6
        static let avatarWidth: CGFloat = 15 * UIScreen.main.nativeScale
        static let avatarContainerInset: CGFloat = 12
        static let avatarCloudInset: CGFloat = 3.5
        static let textInset: CGFloat = 16
        static let timeInset: CGFloat = 8
    }
    
    var cloudHeight: CGFloat = 90
    var cloudWidth: CGFloat = 250
    var id: String = ""
    
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
        label.font = UIFont.teambrella(size: 10)
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
    
    var cloudInsetX: CGFloat {
        return isMy
            ? Constant.avatarContainerInset + Constant.avatarCloudInset
            : Constant.avatarContainerInset + Constant.avatarWidth + Constant.avatarCloudInset
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        if isMy {
            prepareMyCloud(in: context)
        } else {
            prepareTheirCloud(in: context)
        }
        context.setLineWidth(1)
        context.drawPath(using: .fillStroke)
    }
    
    @discardableResult
    func prepare(with model: ChatCellModel, cloudWidth: CGFloat, cloudHeight: CGFloat) -> [UIView] {
        if let model = model as? ChatTextCellModel, model.id != id {
            id = model.id
            isMy = model.isMy
            self.cloudWidth = cloudWidth
            self.cloudHeight = cloudHeight
            setNeedsDisplay()
            
            let baseFrame = CGRect(x: 0, y: 0, width: cloudWidth, height: 20)
            setupLeftLabel(name: model.userName, baseFrame: baseFrame)
            setupRightLabel(rateText: model.rateText, baseFrame: baseFrame)
            setupBottomLabel(date: model.date, baseFrame: baseFrame)
            setupAvatar(avatar: model.userAvatar, cloudHeight: cloudHeight)
            return setupFragments(fragments: model.fragments, heights: model.fragmentHeights)
        } else if let model = model as? ChatTextUnsentCellModel {
            id = model.id
            isMy = true
            self.cloudWidth = cloudWidth
            self.cloudHeight = cloudHeight
            setNeedsDisplay()
            
            let baseFrame = CGRect(x: 0, y: 0, width: cloudWidth, height: 20)
            setupLeftLabel(name: model.userName, baseFrame: baseFrame)
            setupRightLabel(rateText: nil, baseFrame: baseFrame)
            setupBottomLabel(date: model.date, baseFrame: baseFrame)
            // setupAvatar(avatar: nil, cloudHeight: cloudHeight)
            return setupFragments(fragments: model.fragments, heights: model.fragmentHeights)
        } else {
            return []
        }
    }
    
    // MARK: Private
    
    private func prepareMyCloud(in context: CGContext) {
        var pen: CGPoint = cloudStartPoint
        context.move(to: pen)
        pen.y -= Constant.tailSoftening
        pen.x -= Constant.tailSoftening
        context.move(to: pen)
        pen.x -= Constant.tailWidth - Constant.tailSoftening
        pen.y -= Constant.tailHeight - Constant.tailSoftening
        context.addLine(to: pen)
        
        pen.y = Constant.cloudCornerRadius
        context.addLine(to: pen)
        
        var controlP = CGPoint(x: pen.x, y: 0)
        pen.x -= Constant.cloudCornerRadius
        pen.y = 0
        context.addQuadCurve(to: pen, control: controlP)
        
        pen.x = cloudBodyMinX + Constant.cloudCornerRadius
        context.addLine(to: pen)
        
        pen.x = cloudBodyMinX
        pen.y = Constant.cloudCornerRadius
        controlP = CGPoint(x: cloudBodyMinX, y: 0)
        context.addQuadCurve(to: pen, control: controlP)
        
        pen.y = cloudHeight - Constant.cloudCornerRadius
        context.addLine(to: pen)
        
        pen.x += Constant.cloudCornerRadius
        pen.y = cloudHeight
        controlP = CGPoint(x: cloudBodyMinX, y: cloudHeight)
        context.addQuadCurve(to: pen, control: controlP)
        
        pen.x = cloudStartPoint.x - Constant.tailSoftening
        context.addLine(to: pen)
        
        pen.y -= Constant.tailSoftening
        controlP = CGPoint(x: cloudStartPoint.x, y: cloudStartPoint.y - Constant.tailCornerRadius)
        context.addQuadCurve(to: pen, control: controlP)
        context.closePath()
        
        context.setLineWidth(0.5)
        context.setFillColor(UIColor.veryLightBlue.cgColor)
        context.setStrokeColor(#colorLiteral(red: 0.8039215686, green: 0.8666666667, blue: 0.9529411765, alpha: 1).cgColor)
    }
    
    private func prepareTheirCloud(in context: CGContext) {
        var pen: CGPoint = cloudStartPoint
        context.move(to: pen)
        pen.x += Constant.tailSoftening
        pen.y -= Constant.tailSoftening
        context.move(to: pen)
        pen.x += Constant.tailWidth - Constant.tailSoftening
        pen.y -= Constant.tailHeight - Constant.tailSoftening
        context.addLine(to: pen)
        
        pen.y = Constant.cloudCornerRadius
        context.addLine(to: pen)
        
        var controlP = CGPoint(x: pen.x, y: 0)
        pen.x += Constant.cloudCornerRadius
        pen.y = 0
        context.addQuadCurve(to: pen, control: controlP)
        
        pen.x = cloudBodyMaxX - Constant.cloudCornerRadius
        context.addLine(to: pen)
        
        pen.x = cloudBodyMaxX
        pen.y = Constant.cloudCornerRadius
        controlP = CGPoint(x: cloudBodyMaxX, y: 0)
        context.addQuadCurve(to: pen, control: controlP)
        
        pen.y = cloudHeight - Constant.cloudCornerRadius
        context.addLine(to: pen)
        
        pen.x -= Constant.cloudCornerRadius
        pen.y = cloudHeight
        controlP = CGPoint(x: cloudBodyMaxX, y: cloudHeight)
        context.addQuadCurve(to: pen, control: controlP)
        
        pen.x = cloudStartPoint.x + Constant.tailSoftening
        context.addLine(to: pen)
        
        pen.y -= Constant.tailSoftening
        controlP = CGPoint(x: cloudStartPoint.x, y: cloudStartPoint.y - Constant.tailCornerRadius)
        context.addQuadCurve(to: pen, control: controlP)
        
        context.closePath()
        
        context.setLineWidth(0.5)
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.lightBlueGray.cgColor)
    }
    
    private func setupAvatar(avatar: Avatar?, cloudHeight: CGFloat) {
        guard  isMy == false, let avatar = avatar else {
            avatarView.isHidden = true
            return
        }
        
        avatarView.isHidden = false
        avatarView.show(avatar)
        let x = isMy ? width - Constant.avatarContainerInset - Constant.avatarWidth : Constant.avatarContainerInset
        avatarView.frame = CGRect(x: x,
                                  y: cloudHeight - Constant.avatarWidth,
                                  width: Constant.avatarWidth,
                                  height: Constant.avatarWidth)
    }
    
    private func setupLeftLabel(name: Name, baseFrame: CGRect) {
        leftLabel.frame = baseFrame
        leftLabel.text = name.entire
        leftLabel.sizeToFit()
        leftLabel.center = CGPoint(x: cloudBodyMinX + leftLabel.frame.width / 2 + Constant.textInset,
                                   y: leftLabel.frame.height / 2 + Constant.textInset / 2)
    }
    
    private func setupRightLabel(rateText: String?, baseFrame: CGRect) {
        rightLabel.frame = baseFrame
        if let rate = rateText {
            rightLabel.isHidden = false
            rightLabel.text = rate
            rightLabel.sizeToFit()
            rightLabel.center = CGPoint(x: cloudBodyMaxX - rightLabel.frame.width / 2 - Constant.timeInset,
                                        y: leftLabel.frame.minY + rightLabel.frame.height / 2)
            if leftLabel.frame.maxX > rightLabel.frame.minX - 8 {
                leftLabel.frame.size.width -= leftLabel.frame.maxX - (rightLabel.frame.minX - Constant.timeInset)
            }
        } else {
            rightLabel.isHidden = true
        }
    }
    
    private func setupBottomLabel(date: Date, baseFrame: CGRect) {
        bottomLabel.frame = baseFrame
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.timeStyle = .short
        bottomLabel.text = dateFormatter.string(from: date)
        bottomLabel.sizeToFit()
        bottomLabel.center = CGPoint(x: cloudBodyMaxX - bottomLabel.frame.width / 2 - Constant.timeInset,
                                     y: cloudHeight - bottomLabel.frame.height / 2 - Constant.timeInset)
    }
    
    private func setupFragments(fragments: [ChatFragment], heights: [CGFloat]) -> [UIView] {
        views.forEach { $0.removeFromSuperview() }
        views.removeAll()
        
        var result: [UIView] = []
        for (idx, fragment) in fragments.enumerated() {
            switch fragment {
            case let .text(text):
                let textView: UITextView = createTextView(for: text, height: heights[idx])
                contentView.addSubview(textView)
                views.append(textView)
                result.append(textView)
            case let .image(urlString: urlString, urlStringSmall: urlStringSmall, aspect: _):
                let imageView = createGalleryView(for: urlString, small: urlStringSmall, height: heights[idx])
                contentView.addSubview(imageView)
                views.append(imageView)
                result.append(imageView)
            }
        }
        return result
    }
    
    private func createTextView(for text: String, height: CGFloat) -> UITextView {
        let verticalOffset: CGFloat
        if let lastMaxY = views.last?.frame.maxY {
            verticalOffset = lastMaxY + 8
        } else {
            verticalOffset = leftLabel.frame.maxY + 8
        }
        let textView = UITextView(frame: CGRect(x: cloudBodyMinX + Constant.textInset,
                                                y: verticalOffset,
                                                width: cloudWidth - Constant.textInset * 2,
                                                height: height))
        
        textView.textColor = .charcoalGray
        textView.text = text
        textView.font = UIFont.teambrella(size: 14)
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.dataDetectorTypes = .all
        textView.isScrollEnabled = false
        
        // fix (remove) textView top padding
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        return textView
    }
    
    private func createGalleryView(for urlString: String, small: String, height: CGFloat) -> UIImageView {
        let verticalOffset = views.last?.frame.maxY ?? leftLabel.frame.maxY + 8
        let separator: CGFloat = 2.0
        let imageView = ChatImageView(frame: CGRect(x: cloudBodyMinX + separator,
                                                  y: verticalOffset + separator,
                                                  width: cloudWidth - separator * 2,
                                                  height: height))
         imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.setStartingImage(small: small, large: urlString)
        imageView.onTap = { [weak self] galleryView in
            self?.onTap(galleryView: galleryView)
        }
        return imageView
    }
    
    private func onTap(galleryView: GalleryView) {
        onTapImage?(self, galleryView)
    }
    
}

class ChatImageView: UIImageView {
    var galleryImages: [String] = []
    var startingImageString: String?
    var onTap: ((GalleryView) -> Void)?
    
    var galleryView: GalleryView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapView))
        addGestureRecognizer(tap)
    }
    
    func setStartingImage(small: String, large: String) {
        self.showImage(string: small)
        startingImageString = large
        
        galleryView?.removeFromSuperview()
        let imageView = GalleryView(frame: bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.present(imageString: large)
        galleryView = imageView
    }
    
    @objc
    func tapView(sender: UITapGestureRecognizer) {
        guard let galleryView = galleryView else { return }
   
        self.addSubview(galleryView)
        self.onTap?(galleryView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
