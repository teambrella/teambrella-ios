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

class ChatVariousContentCell: ChatUserDataCell {

    
    lazy var leftLabel: Label = {
        let label = Label()
        label.font = Constant.leftLabelFont
        label.textColor = .darkSkyBlue
        self.contentView.addSubview(label)
        return label
    }()
    
    lazy var rightLabel: Label = {
        let label = Label()
        label.font = Constant.rightLabelFont
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
    
    lazy var likedLabel: Label = {
        let label = Label()
        label.font = UIFont.teambrella(size: 10)
        label.textColor = .bluishGray
        self.contentView.addSubview(label)
        return label
    }()
    
    var views: [UIView] = []
    
    
    override var cloudInsetX: CGFloat {
        return isMy
            ? Constant.avatarContainerInset + Constant.avatarCloudInset
            : Constant.avatarContainerInset + Constant.avatarWidth + Constant.avatarCloudInset
    }
    
    
    var onTapImage: ((ChatVariousContentCell, GalleryView) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
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
    func prepare(with model: ChatCellModel, myVote: Double?, type: UniversalChatType, size: CGSize) -> [UIView] {
        if let model = model as? ChatTextCellModel, model.id != id {
            id = model.id
            isMy = model.isMy
            self.cloudWidth = size.width
            self.cloudHeight = size.height
            setNeedsDisplay()
            
            let baseFrame = CGRect(x: 0, y: 0, width: cloudWidth, height: Constant.auxillaryLabelHeight)
            setupLeftLabel(name: model.userName, baseFrame: baseFrame)
            if isMy, let vote = myVote {
                let builder = ChatModelBuilder()
                let text = builder.rateText(rate: vote, showRate: true, isClaim: type == .claim)
                setupRightLabel(rateText: text, baseFrame: baseFrame)
            } else {
                setupRightLabel(rateText: model.rateText, baseFrame: baseFrame)
            }
            setupBottomLabel(date: model.date, baseFrame: baseFrame)
            setupLikedLabel(liked: model.liked, baseFrame: baseFrame)
            setupAvatar(avatar: model.userAvatar, cloudHeight: cloudHeight)
            return setupFragments(fragments: model.fragments, sizes: model.fragmentSizes)
        } else {
            return []
        }
    }
    
    private func setupLeftLabel(name: Name, baseFrame: CGRect) {
        leftLabel.frame = baseFrame
        leftLabel.text = name.entire
        leftLabel.sizeToFit()
        leftLabel.center = CGPoint(x: cloudBodyMinX + leftLabel.frame.width / 2 + Constant.textInset,
                                   y: leftLabel.frame.height / 2 + Constant.textInset)
    }
    
    private func setupRightLabel(rateText: String?, baseFrame: CGRect) {
        rightLabel.frame = baseFrame
        if let rate = rateText {
            rightLabel.isHidden = false
            rightLabel.text = rate
            rightLabel.sizeToFit()
            rightLabel.center = CGPoint(x: cloudBodyMaxX - rightLabel.frame.width / 2 - Constant.timeInset,
                                        y: leftLabel.frame.maxY - rightLabel.frame.height / 2 - 0.5)
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
    
    override func setupLikedLabel(liked: Int, baseFrame: CGRect) {
        likedLabel.frame = baseFrame
        let prefix = liked > 0 ? "+" : ""
        likedLabel.text = prefix + String(liked)
        likedLabel.sizeToFit()
        likedLabel.center = CGPoint(x: cloudBodyMinX + leftLabel.frame.width / 2 + Constant.textInset,
                                    y: cloudHeight - likedLabel.frame.height / 2 - Constant.timeInset)
        likedLabel.isHidden = liked == 0
    }
    
    private func setupFragments(fragments: [ChatFragment], sizes: [CGSize]) -> [UIView] {
        views.forEach { $0.removeFromSuperview() }
        views.removeAll()
        
        var result: [UIView] = []
        for (idx, fragment) in fragments.enumerated() {
            switch fragment {
            case let .text(text):
                let textView: UITextView = createTextView(for: text, size: sizes[idx])
                contentView.addSubview(textView)
                views.append(textView)
                result.append(textView)
            case let .image(urlString: urlString, urlStringSmall: urlStringSmall, aspect: _):
                let imageView = createGalleryView(for: urlString, small: urlStringSmall, height: sizes[idx].height)
                contentView.addSubview(imageView)
                views.append(imageView)
                result.append(imageView)
            }
        }
        return result
    }
    
    private func createTextView(for text: String, size: CGSize) -> UITextView {
        let verticalOffset: CGFloat
        if let lastMaxY = views.last?.frame.maxY {
            verticalOffset = lastMaxY + 8
        } else {
            verticalOffset = leftLabel.frame.maxY + 8
        }
        let textView = UITextView(frame: CGRect(x: cloudBodyMinX + Constant.textInset,
                                                y: verticalOffset,
                                                width: size.width,
                                                height: size.height))
        
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
        self.showImage(string: small, needHeaders: true)
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
