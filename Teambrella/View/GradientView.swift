//
//  GradientView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.05.17.

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

/**
 *  Vertical gradient view
 */
@IBDesignable
public class GradientView: UIView {
    
    @IBInspectable public var topColor: UIColor? = UIColor.clear
    @IBInspectable public var bottomColor: UIColor? = UIColor.black
    @IBInspectable public var horizontal: Bool = false
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
        if horizontal {
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
        gradientLayer.locations = locations
    }
    
    override public func layoutSubviews() {
        gradientLayer.frame = self.layer.bounds
        updateGradient()
        super.layoutSubviews()
    }
    
}
