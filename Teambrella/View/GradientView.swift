//
//  GradientView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

/**
 *  Vertical gradient view
 */
@IBDesignable
public class GradientView: UIView {
    
    @IBInspectable
    public var topColor: UIColor? = UIColor.clear
    @IBInspectable
    public var bottomColor: UIColor? = UIColor.black
    
    fileprivate let gradientLayer: CAGradientLayer = CAGradientLayer()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    fileprivate func updateGradient() {
        if gradientLayer.superlayer == nil { self.layer.addSublayer(gradientLayer) }
        if let top = topColor, let bottom = bottomColor {
            gradientLayer.colors = [top.cgColor, bottom.cgColor]
            gradientLayer.locations = [ 0.0, 1.0]
        }
    }
    
    override public func layoutSubviews() {
        gradientLayer.frame = self.layer.bounds
        updateGradient()
        super.layoutSubviews()
    }
}
