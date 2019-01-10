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


class ChatUserDataCell: UICollectionViewCell {
    struct Constant {
        static let tailWidth: CGFloat = 8
        static let tailHeight: CGFloat = 8
        static let tailSoftening: CGFloat = 3
        static let tailCornerRadius: CGFloat = 1
        static let cloudCornerRadius: CGFloat = 6
        static let avatarWidth: CGFloat = 18 * UIScreen.main.nativeScale
        static let avatarContainerInset: CGFloat = 12
        static let avatarCloudInset: CGFloat = 3.5
        static let textInset: CGFloat = 8
        static let imageInset: CGFloat = 2.0
        static let labelToTextVerticalInset: CGFloat = 4
        static let timeInset: CGFloat = 8
        static let auxillaryLabelHeight: CGFloat = 20
        static let leftLabelFont = UIFont.teambrella(size: 12)
        static let rightLabelFont = UIFont.teambrella(size: 10)
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
    
    var onInitiateCommandList: ((ChatUserDataCell) -> Void)?

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
        if isMy {
            return avatarView.isHidden
                ? Constant.avatarCloudInset
                : Constant.avatarContainerInset + Constant.avatarCloudInset
        } else {
            return avatarView.isHidden
                ? Constant.avatarCloudInset
                : Constant.avatarContainerInset + Constant.avatarWidth + Constant.avatarCloudInset
        }
    }

    func isWithinFrame(point: CGPoint) -> Bool {
        return point.x >= cloudBodyMinX && point.x <= cloudBodyMaxX
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

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


    func prepareMyCloud(in context: CGContext) {
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
        
        context.setFillColor(UIColor.veryLightBlue.cgColor)
        context.setStrokeColor(#colorLiteral(red: 0.8039215686, green: 0.8666666667, blue: 0.9529411765, alpha: 1).cgColor)
    }

    func prepareTheirCloud(in context: CGContext) {
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
        
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.lightBlueGray.cgColor)
    }

    func setupAvatar(avatar: Avatar?, cloudHeight: CGFloat) {
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
    
    func setupLikedLabel(liked: Int, baseFrame: CGRect) {
    }

}
