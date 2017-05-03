//
//  RoundImageView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 03.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

@IBDesignable
class RoundImageView: UIImageView {
    private let imageView = UIImageView()
    private var limbView: UIView?
    @IBInspectable
    override var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
     var limbColor: UIColor? {
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
 
    override var contentMode: UIViewContentMode {
        didSet {
            imageView.contentMode = contentMode
        }
    }
    override var frame: CGRect {
        didSet {
            if frame.size.width != frame.size.height {
                let side = frame.size.width > frame.size.height ? frame.size.height : frame.size.width
                frame = CGRect(origin: frame.origin, size: CGSize(width: side, height: side))
            }
        }
    }
    override var bounds: CGRect {
        didSet {
            if bounds.size.width != bounds.size.height {
                let side = bounds.size.width > bounds.size.height ? bounds.size.height : bounds.size.width
                bounds = CGRect(origin: bounds.origin, size: CGSize(width: side, height: side))
            }
        }
    }
    @IBInspectable
    var inset: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
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
        addSubview(imageView)
        imageView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSide = bounds.width - inset * 2
        imageView.frame.size = CGSize(width: imageSide, height: imageSide)
        imageView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        imageView.layer.cornerRadius = imageSide / 2
        limbView?.frame = bounds
        limbView?.layer.cornerRadius = bounds.midX
    }
    
}
