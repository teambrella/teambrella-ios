//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import UIKit

class ChatTextCell: ChatUserDataCell {
    
    override func setup() {
        super.setup()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    @objc
    private func handleTap(sender: UITapGestureRecognizer) {
        if isWithinFrame(point: sender.location(in: self)) {
            onInitiateCommandList?(self)
        }
    }

    @objc
    private func handleTapInner(sender: UITapGestureRecognizer) {
        onInitiateCommandList?(self)
    }
    
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

    lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.textColor = .charcoalGray
        textView.font = UIFont.teambrella(size: 14)
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.dataDetectorTypes = .all
        textView.isScrollEnabled = false

        // fix (remove) textView top padding
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        self.contentView.addSubview(textView)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapInner))
        textView.addGestureRecognizer(tapRecognizer)
        
        return textView
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

    lazy var markIcon: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "iconMark"))
        self.contentView.addSubview(view)
        return view
    }()
    

    var onTapImage: ((ChatTextCell, GalleryView) -> Void)?

    func prepare(with model: ChatTextCellModel,
                 myVote: Double?,
                 type: UniversalChatType,
                 size: CGSize) {
        let baseFrame = CGRect(x: 0, y: 0, width: cloudWidth, height: Constant.auxillaryLabelHeight)
        if model.id != id || markIcon.isHidden == model.isMarked {
            id = model.id
            isMy = model.isMy
            self.cloudWidth = size.width
            self.cloudHeight = size.height-2
            setNeedsDisplay()

            setupAvatar(avatar: model.userAvatar, cloudHeight: cloudHeight)
            setupLeftLabel(name: model.userName, baseFrame: baseFrame)
            if isMy, let vote = myVote {
                let builder = ChatModelBuilder()
                let text = builder.rateText(rate: vote, showRate: true, isClaim: type == .claim)
                setupRightLabel(rateText: text, isMarked: model.isMarked, baseFrame: baseFrame)
            } else {
                setupRightLabel(rateText: model.rateText, isMarked: model.isMarked, baseFrame: baseFrame)
            }
            setupBottomLabel(date: model.date, baseFrame: baseFrame)
            markIcon.isHidden = !model.isMarked
            if model.isMarked {
                setupMarkIcon(isMy: model.isMy, baseFrame: baseFrame)
            }
            setupFragments(fragments: model.fragments, sizes: model.fragmentSizes)
        }

        self.alpha = 1
        if (model.grayed >= 0.7) {
            self.alpha = 0.15
        }
        else if (model.grayed >= 0.3) {
            self.alpha = 0.3
        }
        setupLikedLabel(liked: model.liked, baseFrame: baseFrame)
    }

    private func setupLeftLabel(name: Name, baseFrame: CGRect) {
        if name.isEmpty {
            leftLabel.text = nil
            leftLabel.frame = .zero
            leftLabel.center = CGPoint(x: cloudBodyMinX + Constant.textInset,
                                       y: Constant.textInset - Constant.labelToTextVerticalInset)
        } else {
            leftLabel.frame = baseFrame
            leftLabel.text = name.entire
            leftLabel.sizeToFit()
            leftLabel.center = CGPoint(x: cloudBodyMinX + leftLabel.frame.width / 2 + Constant.textInset,
                                       y: leftLabel.frame.height / 2 + Constant.textInset)
        }
    }

    private func setupRightLabel(rateText: String?, isMarked: Bool, baseFrame: CGRect) {
        rightLabel.frame = baseFrame
        if let rate = rateText {
            rightLabel.isHidden = false
            rightLabel.text = rate
            rightLabel.sizeToFit()
            let markOffset = isMarked ? Constant.markWidth + Constant.markXOffset : 0
            rightLabel.center = CGPoint(x: cloudBodyMaxX - rightLabel.frame.width / 2 - Constant.timeInset - markOffset,
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
    
    private func setupMarkIcon(isMy: Bool, baseFrame: CGRect) {
        markIcon.frame = CGRect(x: 0, y: 0, width: Constant.markWidth, height: Constant.markHeight)
        markIcon.center = CGPoint(x: cloudBodyMaxX - markIcon.frame.width / 2 - Constant.timeInset,
                                  y: baseFrame.maxY - markIcon.frame.height / 2 + Constant.markYOffset)
    }
    

    override func setupLikedLabel(liked: Int, baseFrame: CGRect) {
        likedLabel.frame = baseFrame
        let prefix = liked > 0 ? "+" : ""
        likedLabel.text = prefix + String(liked)
        likedLabel.sizeToFit()
        likedLabel.center = CGPoint(x: cloudBodyMinX + likedLabel.frame.width / 2 + Constant.textInset,
                                    y: cloudHeight - likedLabel.frame.height / 2 - Constant.timeInset)
        likedLabel.isHidden = liked == 0
    }

    private func setupFragments(fragments: [ChatFragment], sizes: [CGSize]) {
        for (idx, fragment) in fragments.enumerated() {
            switch fragment {
            case let .text(text):
                updateTextView(for: text, size: sizes[idx])
            default:
                break
            }
        }
    }

    private func updateTextView(for text: String, size: CGSize) {
        let verticalOffset: CGFloat = leftLabel.frame.maxY + Constant.labelToTextVerticalInset
        textView.frame = CGRect(x: cloudBodyMinX + Constant.textInset,
                                y: verticalOffset,
                                width: size.width,
                                height: size.height)
        textView.text = text
    }

    @objc
    private func onTap(galleryView: GalleryView) {
        onTapImage?(self, galleryView)
    }
}
