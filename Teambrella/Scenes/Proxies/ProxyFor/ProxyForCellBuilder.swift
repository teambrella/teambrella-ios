//
//  ProxyForCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct ProxyForCellBuilder {
    static func populate(cell: UICollectionViewCell, with model: ProxyForCellModel) {
        if let cell = cell as? ProxyForCell {
            cell.avatarView.showAvatar(string: model.avatarString)
            cell.nameLabel.text = model.name
            cell.amountLabel.text = "$" + String(model.amount)
            
            guard let lastVoted = model.lastVoted else { return }
            
            let dateString = DateProcessor().stringInterval(from: lastVoted)
            cell.detailsLabel.text = "LAST VOTED: " + dateString //
            
        }
    }
    
}
