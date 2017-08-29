//
//  TeammateVoteCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.06.17.

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

class TeammateVoteCell: UICollectionViewCell {
    @IBOutlet var container: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CellDecorator.shadow(for: self)
        CellDecorator.roundedEdges(for: self)
    }
    
    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        contentView.layoutMargins = layoutMargins
    }
    
}
