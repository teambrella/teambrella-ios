//
//  ItemCard.swift
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
class ItemCard: UIView, XIBInitable {
    @IBOutlet var avatarView: GalleryView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        setup()
    }
    
    func setup() {
        avatarView.layer.cornerRadius = 2
        avatarView.layer.masksToBounds = true
    }
}
