//
//  HomeApplicationStatusCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 07.07.17.

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

class HomeApplicationStatusCell: CancellableCell {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var avatar: RoundImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var centerLabel: UILabel!
    @IBOutlet var bottomLabel: UILabel!
    @IBOutlet var messageCountLabel: UILabel!

    @IBAction func tapButton(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CellDecorator.roundedEdges(for: self)
        CellDecorator.shadow(for: self)
    }
}
