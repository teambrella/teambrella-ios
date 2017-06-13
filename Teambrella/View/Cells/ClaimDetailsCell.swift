//
//  ClaimDetailsCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
