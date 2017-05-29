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
    var badge: Label?
    
    var badgeFont: UIFont?
    var badgeTextColor: UIColor?
    var badgeText: String? {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if badgeText != nil {
            if badge == nil {
                let badge = Label(frame: .zero)
                addSubview(badge)
            }
            guard let badge = badge else { fatalError("Badge should be instantiated") }
            
            badge.font = badgeFont
            badge.textColor = badgeTextColor
            badge.text = badgeText
            badge.center = CGPoint(x: bounds.maxX, y: badge.frame.height / 2)
        } else {
            badge?.removeFromSuperview()
            badge = nil
        }
    }

}
