//
//  BorderedButton.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 27.05.17.

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
class BorderedButton: UIButton {
  
    override var isEnabled: Bool {
        didSet {
            layer.borderColor = self.titleColor(for: state)?.cgColor
        }
    }
    
    @IBInspectable var borderColor: UIColor = .robinEggBlue {
        didSet {
            setup()
        }
    }
    
    @IBInspectable var hasGradientBackground: Bool = false {
        didSet {
            setup()
        }
    }
    
    @IBInspectable var shadowColor: UIColor = #colorLiteral(red: 0.568627451, green: 0.8784313725, blue: 1, alpha: 0.2) {
        didSet {
            setup()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        layer.cornerRadius = 3
        layer.borderWidth = 1
        layer.borderColor = borderColor.cgColor
        ViewDecorator.shadow(for: self,
                             color: shadowColor,
                             opacity: 1,
                             radius: 4,
                             offset: CGSize(width: 0, height: 4))
        if hasGradientBackground {
            let gradientView = GradientView(frame: self.bounds)
            gradientView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            gradientView.topColor = #colorLiteral(red: 0.2549019608, green: 0.3058823529, blue: 0.8, alpha: 1)
            gradientView.bottomColor = #colorLiteral(red: 0.4078431373, green: 0.4549019608, blue: 0.9058823529, alpha: 1)
            layer.borderColor = #colorLiteral(red: 0.2862745098, green: 0.3490196078, blue: 0.9019607843, alpha: 1)
            layer.masksToBounds = true
            gradientView.isUserInteractionEnabled = false
            insertSubview(gradientView, at: 0)
        }
    }
}
