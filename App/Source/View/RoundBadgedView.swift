//
//  RoundBadgedView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.05.17.

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
class RoundBadgedView: RoundImageView {
    lazy var badge: Label = {
        let badge = Label(frame: self.bounds)
        badge.textInsets = UIEdgeInsets(top: 1, left: 5, bottom: 1, right: 5)
        badge.textColor = self.badgeTextColor
        badge.layer.masksToBounds = true
        badge.layer.cornerRadius = 4
        badge.layer.borderWidth = 1.5
        badge.layer.borderColor = self.badgeTextColor.cgColor
        badge.backgroundColor = UIColor.blueyGray
        self.addSubview(badge)
        return badge
    }()
    
    var badgeFont: UIFont = UIFont.teambrella(size: 10)
    var badgeTextColor: UIColor = .white
    var badgeText: String? {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if badgeText != nil {
            badge.frame = self.bounds
            badge.font = badgeFont
            badge.textColor = badgeTextColor
            badge.text = badgeText
            badge.sizeToFit()
            badge.center = CGPoint(x: bounds.maxX - 3, y: 3)
        }
    }

}
