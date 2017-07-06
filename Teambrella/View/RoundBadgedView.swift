//
//  RoundBadgedView.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 29.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

@IBDesignable
class RoundBadgedView: RoundImageView {
    lazy var badge: Label = {
        let badge = Label(frame: self.bounds)
        badge.textInsets = UIEdgeInsets(top: 1, left: 3, bottom: 1, right: 3)
        badge.textColor = self.badgeTextColor
        badge.layer.masksToBounds = true
        badge.layer.cornerRadius = 3
        badge.layer.borderWidth = 1
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
            badge.center = CGPoint(x: bounds.maxX, y: 0)
        }
    }

}
