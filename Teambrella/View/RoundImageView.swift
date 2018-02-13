//
//  RoundImageView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 03.05.17.

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

import UIKit

@IBDesignable
class RoundImageView: UIImageView {
    private let imageView = UIImageView()
    private var limbView: UIView?
    private var label: UILabel?
    @IBInspectable override var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = nil
            imageView.image = newValue
        }
    }
    @IBInspectable var limbColor: UIColor? {
        get {
            return limbView?.backgroundColor
        }
        set {
            if limbView == nil {
                let view = UIView(frame: bounds)
                view.layer.masksToBounds = true
                insertSubview(view, belowSubview: imageView)
                limbView = view
                setNeedsLayout()
            }
            limbView?.backgroundColor = newValue
        }
    }
    @IBInspectable var viewColor: UIColor? {
        get {
            return imageView.backgroundColor
        }
        set {
            imageView.backgroundColor = newValue
        }
    }
    @IBInspectable var text: String? {
        get {
            return label?.text
        }
        set {
            if label == nil {
                let newLabel = UILabel()
                newLabel.numberOfLines = 1
                newLabel.textAlignment = .center
                newLabel.adjustsFontSizeToFitWidth = true
                newLabel.font = UIFont.teambrellaBold(size: 13)
                label = newLabel
                insertSubview(newLabel, aboveSubview: imageView)
            }
            label?.text = newValue
        }
    }
    @IBInspectable var textColor: UIColor?
    
    var font: UIFont?
    
    override var contentMode: UIViewContentMode {
        didSet {
            imageView.contentMode = contentMode
        }
    }

    @IBInspectable var inset: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    init() {
        super.init(frame: .zero)
        setup()
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
        addSubview(imageView)
//        imageView.image = #imageLiteral(resourceName: "imagePlaceholder")
        imageView.layer.masksToBounds = true
        contentMode = .scaleAspectFill
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let side = bounds.width > bounds.height ? bounds.height : bounds.width
        let imageSide = side - inset * 2
        imageView.frame.size = CGSize(width: imageSide, height: imageSide)
        imageView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        imageView.layer.cornerRadius = imageSide / 2
        limbView?.frame.size = CGSize(width: side, height: side)
        limbView?.center = imageView.center
        limbView?.layer.cornerRadius = side / 2
        if let label = label {
            label.frame.size = imageView.bounds.size
            label.center = imageView.center
            font.map { label.font = $0 }
            textColor.map { label.textColor = $0 }
        }
    }
    
}
