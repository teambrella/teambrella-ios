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

protocol ChatUserDataCell {

}

class ChatImageCell: UICollectionViewCell, ChatUserDataCell {
    struct Constant {
        static let cloudCornerRadius: CGFloat = 6
        static let imageInset: CGFloat = 2.0
        static let avatarWidth: CGFloat = 15 * UIScreen.main.nativeScale
        static let avatarContainerInset: CGFloat = 12
        static let avatarCloudInset: CGFloat = 3.5
        static let timeInset: CGFloat = 8
        static let auxillaryLabelHeight: CGFloat = 20
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

    lazy var bottomLabel: Label = {
        let label = Label()
        label.font = UIFont.teambrella(size: 10)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        label.textInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        self.contentView.addSubview(label)
        return label
    }()

    lazy var imageView: ChatImageView = {
        let verticalOffset = 8
        let imageView = ChatImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.onTap = { [weak self] galleryView in
            self?.onTap(galleryView: galleryView)
        }
        self.contentView.addSubview(imageView)
        return imageView
    }()

    lazy var hidingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        self.contentView.addSubview(view)
        return view
    }()

    lazy var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        hidingView.addSubview(view)
        view.startAnimating()
        return view
    }()

    lazy var deleteButton: UIButton = {
        let size: CGFloat = 40
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: size, height: size)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        button.setImage(#imageLiteral(resourceName: "crossIcon"), for: .normal)
        button.addTarget(self, action: #selector(tapDelete), for: .touchUpInside)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        self.contentView.addSubview(button)
        return button
    }()

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
            return cloudStartPoint.x - cloudWidth
        } else {
            return cloudStartPoint.x
        }
    }
    var cloudBodyMaxX: CGFloat {
        if isMy {
            return cloudStartPoint.x
        } else {
            return cloudStartPoint.x + cloudWidth
        }
    }

    var isMy: Bool = false {
        didSet {
            avatarView.isUserInteractionEnabled = !isMy
        }
    }

    var onTapImage: ((ChatImageCell, GalleryView) -> Void)?
    var onTapDelete: ((ChatImageCell) -> Void)?

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

    func prepareRealCell(model: ChatCellUserDataLike, size: CGSize) {
        if model.id != id, let fragment = model.fragments.first {

            id = model.id
            isMy = model.isMy
            self.cloudWidth = size.width
            self.cloudHeight = size.height

            imageView.frame = CGRect(x: Constant.imageInset,
                                     y: Constant.imageInset,
                                     width: self.cloudWidth - Constant.imageInset * 2,
                                     height: self.cloudHeight - Constant.imageInset * 2)
            imageView.roundCorners(.allCorners, radius: Constant.cloudCornerRadius - Constant.imageInset / 2)
            hidingView.isHidden = true
            setNeedsDisplay()

            let baseFrame = CGRect(x: 0, y: 0, width: cloudWidth, height: Constant.auxillaryLabelHeight)
            setupFragment(fragment: fragment)
            var certified = false
            if case let .image(imageString, _, _) = fragment {
                certified = imageString.contains("@cam")
            }
            setupBottomLabel(date: model.date, baseFrame: baseFrame, isCertifiedImage: certified)
            setupAvatar(avatar: model.userAvatar, cloudHeight: cloudHeight)
            setupDeleteButton(isDeletable: model.isDeletable)
        }
    }

    func prepareUnsentCell(model: ChatUnsentImageCellModel, size: CGSize, image: UIImage?) {
        id = model.id
        isMy = true
        self.cloudWidth = size.width
        self.cloudHeight = size.height

        imageView.frame = CGRect(x: Constant.imageInset,
                                 y: Constant.imageInset,
                                 width: self.cloudWidth - Constant.imageInset * 2,
                                 height: self.cloudHeight - Constant.imageInset * 2)
         imageView.roundCorners(.allCorners, radius: Constant.cloudCornerRadius - Constant.imageInset / 2)

        setNeedsDisplay()

        let baseFrame = CGRect(x: 0, y: 0, width: cloudWidth, height: Constant.auxillaryLabelHeight)
        imageView.frame = CGRect(x: cloudBodyMinX + Constant.imageInset,
                                 y: Constant.imageInset,
                                 width: cloudWidth - Constant.imageInset * 2,
                                 height: cloudHeight - Constant.imageInset * 2)

        imageView.image = image

        hidingView.frame = imageView.frame
        hidingView.roundCorners(.allCorners, radius: Constant.cloudCornerRadius - Constant.imageInset / 2)
        hidingView.isHidden = false

        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.center = CGPoint(x: hidingView.bounds.midX, y: hidingView.bounds.midY)
        spinner.startAnimating()

        setupBottomLabel(date: model.date, baseFrame: baseFrame, isCertifiedImage: false)
        setupDeleteButton(isDeletable: model.isDeletable)
        }

    // MARK: Private

    private func prepareMyCloud(in context: CGContext) {
        var pen: CGPoint = cloudStartPoint
        pen.y -= Constant.cloudCornerRadius
        context.move(to: pen)

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

        pen.x = cloudStartPoint.x - Constant.cloudCornerRadius
        context.addLine(to: pen)

        pen.x += Constant.cloudCornerRadius
        pen.y = cloudHeight - Constant.cloudCornerRadius
        controlP = cloudStartPoint
        context.addQuadCurve(to: pen, control: controlP)
        context.closePath()

        context.setFillColor(UIColor.veryLightBlue.cgColor)
        context.setStrokeColor(#colorLiteral(red: 0.8039215686, green: 0.8666666667, blue: 0.9529411765, alpha: 1).cgColor)
    }

    private func prepareTheirCloud(in context: CGContext) {
        var pen: CGPoint = cloudStartPoint
        pen.y -= Constant.cloudCornerRadius
        context.move(to: pen)
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

        pen.x = cloudStartPoint.x + Constant.cloudCornerRadius
        context.addLine(to: pen)

        pen.x -= Constant.cloudCornerRadius
        pen.y = cloudHeight - Constant.cloudCornerRadius
        controlP = cloudStartPoint
        context.addQuadCurve(to: pen, control: controlP)
        context.closePath()

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

    private func setupBottomLabel(date: Date, baseFrame: CGRect, isCertifiedImage: Bool) {
        bottomLabel.frame = baseFrame
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.timeStyle = .short
        let prefix = isCertifiedImage ? "📷 " : ""
        bottomLabel.text = prefix + dateFormatter.string(from: date)
        bottomLabel.sizeToFit()
        bottomLabel.cornerRadius = bottomLabel.frame.height / 2
        bottomLabel.center = CGPoint(x: cloudBodyMaxX - bottomLabel.frame.width / 2 - Constant.timeInset,
                                     y: cloudHeight - bottomLabel.frame.height / 2 - Constant.timeInset)
    }

    private func setupFragment(fragment: ChatFragment) {
        switch fragment {
        case let .image(urlString: urlString, urlStringSmall: urlStringSmall, aspect: _):
            imageView.frame = CGRect(x: cloudBodyMinX + Constant.imageInset,
                                     y: Constant.imageInset,
                                     width: cloudWidth - Constant.imageInset * 2,
                                     height: cloudHeight - Constant.imageInset * 2)
            imageView.setStartingImage(small: urlStringSmall, large: urlString)
        default:
            break
        }
    }

    private func setupDeleteButton(isDeletable: Bool) {
        if isDeletable {
            deleteButton.center = CGPoint(x: imageView.frame.maxX - deleteButton.frame.width / 2,
                                          y: imageView.frame.minY + deleteButton.frame.height / 2)
        }
        deleteButton.isHidden = !isDeletable
    }

    @objc
    private func tapDelete() {
        onTapDelete?(self)
    }

    private func onTap(galleryView: GalleryView) {
        onTapImage?(self, galleryView)
    }
}
