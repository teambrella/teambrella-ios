//
//  TeammateStatsCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class TeammateStatsCell: UICollectionViewCell {
    @IBOutlet var headerLabel: BlockHeaderLabel!
    @IBOutlet var numberBar: NumberBar!
    
    @IBOutlet var decisionsLabel: Label!
    @IBOutlet var decisionsBar: ScaleBar!
    
    @IBOutlet var discussionsLabel: Label!
    @IBOutlet var discussionsBar: ScaleBar!
    
    @IBOutlet var frequencyLabel: Label!
    @IBOutlet var frequencyBar: ScaleBar!
    
    @IBOutlet var addButton: BorderedButton!
    
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
