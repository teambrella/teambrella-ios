//
//  TeammateContactCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class TeammateContactCell: UICollectionViewCell {
    @IBOutlet var headerLabel: Label!
    @IBOutlet var tableView: UITableView!
 
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
