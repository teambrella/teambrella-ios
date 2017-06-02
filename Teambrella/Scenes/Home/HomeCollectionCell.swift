//
//  HomeCollectionCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 27.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class HomeCollectionCell: UICollectionViewCell {
    struct Constant {
        static let cornerRadius: CGFloat = 5.0
        static let shadowRadius: CGFloat = 2.0
    }
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var avatarView: UIImageView!
    
    @IBOutlet var leftNumberView: NumberView!
    @IBOutlet var rightNumberView: NumberView!
    
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var unreadCountView: RoundImageView!
    
    func setupShadow() {
       containerView.layer.cornerRadius = Constant.cornerRadius
       containerView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = Constant.shadowRadius
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds,
                                             cornerRadius: containerView.layer.cornerRadius).cgPath
    }
    
}
