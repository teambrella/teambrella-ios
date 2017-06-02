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
    var colors: [UIColor]?
    var locations: [NSNumber] = [0.0, 1.0]
    
    fileprivate let gradientLayer: CAGradientLayer = CAGradientLayer()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // Set as many colors as you like
    func setup(colors: [UIColor], locations: [NSNumber]) {
        guard colors.count == locations.count else { return }
        
        self.colors = colors
        self.locations = locations
        setNeedsLayout()
    }
    
    fileprivate func updateGradient() {
        if gradientLayer.superlayer == nil { self.layer.addSublayer(gradientLayer) }
        if let colors = colors {
            gradientLayer.colors = colors.map { $0.cgColor }
        } else if let top = topColor, let bottom = bottomColor {
            gradientLayer.colors = [top.cgColor, bottom.cgColor]
        }
        gradientLayer.locations = locations
    }
    
    override public func layoutSubviews() {
        gradientLayer.frame = self.layer.bounds
        updateGradient()
        super.layoutSubviews()
    }
    
}
