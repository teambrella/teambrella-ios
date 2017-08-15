//
//  HomeCollectionCell.swift
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
