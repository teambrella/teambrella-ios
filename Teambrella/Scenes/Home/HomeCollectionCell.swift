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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CellDecorator.roundedEdges(for: self)
        CellDecorator.heavyShadow(for: self)
        rightNumberView.isCurrencyOnTop = false
    }
    
}
