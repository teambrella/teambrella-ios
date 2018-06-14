//
//  BrickView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 26.05.17.

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
class BrickView: UIView {
    struct Constant {
        static let standardOffset: CGFloat = 16.0
        static let smallFontSize: CGFloat = 9.0
        static let titleFontSize: CGFloat = 10.0
        static let largeFontSize: CGFloat = 24.0
    }
    
    enum BrickViewCurrencyType {
        case normal
        case upper
        case lower
    }
    
    @IBInspectable var icon: UIImage?
    @IBInspectable var title: String = ""
    @IBInspectable var amount: String = "0"
    @IBInspectable var currency: String = "..."
    @IBInspectable var badge: String?
    
    var currencyType: BrickViewCurrencyType = .normal
    var amountTextColor: UIColor = .black
    var titleTextColor: UIColor = .white50
    var currencyTextColor: UIColor = .darkSkyBlue
    var badgeBackgroundColor: UIColor = .darkSkyBlue
    var badgeTextColor: UIColor = .white
    
    lazy private var iconView: UIImageView = {
        let view = UIImageView()
        self.addSubview(view)
        return view
    }()
    
    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: Constant.titleFontSize)
        label.textColor = self.titleTextColor
        self.addSubview(label)
        return label
    }()
    
    lazy private var amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: Constant.largeFontSize)
        label.textColor = self.amountTextColor
        self.addSubview(label)
        return label
    }()
    
    lazy private var currencyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: Constant.largeFontSize)
        label.textColor = self.currencyTextColor
        self.addSubview(label)
        return label
    }()
    
    lazy private var badgeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: Constant.smallFontSize)
        label.textColor = self.badgeTextColor
        label.backgroundColor = self.badgeBackgroundColor
        self.addSubview(label)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch currencyType {
        case .normal:
            currencyLabel.font = amountLabel.font
        default:
            currencyLabel.font = UIFont(name: amountLabel.font.fontName, size: Constant.smallFontSize)
        }
        
        if let icon = icon {
            iconView.image = icon
            iconView.center = CGPoint(x: iconView.frame.width / 2, y: bounds.midY)
            let x = iconView.frame.maxX + Constant.standardOffset
            amountLabel.frame.origin = CGPoint(x: x, y: iconView.frame.maxY - amountLabel.frame.height)
            titleLabel.frame.origin = CGPoint(x: x, y: iconView.frame.minY)
        } else if let badge = badge {
            titleLabel.center = CGPoint(x: bounds.midX, y: bounds.midY - titleLabel.frame.height / 2)
            
            let wdt = amountLabel.frame.width
                + currencyLabel.frame.width
                + Constant.standardOffset
                + badgeLabel.frame.width
            
            let x = (bounds.width - wdt) / 2
            amountLabel.frame.origin = CGPoint(x: x, y: titleLabel.frame.maxY)
            currencyLabel.frame.origin = CGPoint(x: amountLabel.frame.maxX, y: 0)
            badgeLabel.frame.origin = CGPoint(x: currencyLabel.frame.maxX + Constant.standardOffset,
                                              y: amountLabel.frame.midY)
            badgeLabel.text = badge
        } else {
            titleLabel.center = CGPoint(x: bounds.midX, y: bounds.midY - titleLabel.frame.height / 2)
            
            let wdt = amountLabel.frame.width
                + currencyLabel.frame.width
            
            let x = (bounds.width - wdt) / 2
            amountLabel.frame.origin = CGPoint(x: x, y: titleLabel.frame.maxY)
            currencyLabel.frame.origin = CGPoint(x: amountLabel.frame.maxX, y: 0)
        }
        
        let x = amountLabel.frame.maxX
        switch currencyType {
        case .normal:
            currencyLabel.frame.origin = CGPoint(x: x, y: amountLabel.frame.minY)
        case .lower:
            currencyLabel.frame.origin = CGPoint(x: x, y: amountLabel.frame.maxY - currencyLabel.frame.height)
        case .upper:
            currencyLabel.frame.origin = CGPoint(x: x, y: amountLabel.frame.minY)
        }
    }

}
