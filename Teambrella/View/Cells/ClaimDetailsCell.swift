//
//  ClaimDetailsCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.

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

class ClaimDetailsCell: UICollectionViewCell, XIBInitableCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var infoButton: UIButton!
    
    @IBOutlet var claimAmountLabel: Label!
    @IBOutlet var claimAmountValueLabel: Label!
    
    @IBOutlet var estimatedExpencesLabel: Label!
    @IBOutlet var estimatedExpensesValueLabel: Label!
    
    @IBOutlet var deductibleLabel: Label!
    @IBOutlet var deductibleValueLabel: Label!
    
    @IBOutlet var coverageLabel: Label!
    @IBOutlet var coverageValueLabel: Label!
    
    @IBOutlet var incidentDateLabel: Label!
    @IBOutlet var incidentDateValueLabel: Label!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        CellDecorator.roundedEdges(for: self)
        CellDecorator.shadow(for: self)
    }

}
