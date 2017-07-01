//
//  JoinTeamCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 01.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct JoinTeamCellBuilder {
    static func registerCells(in collectionView: UICollectionView) {
        collectionView.register(JoinTeamGreetingCell.nib, forCellWithReuseIdentifier: JoinTeamGreetingCell.cellID)
    }
    
    static func populate(cell: UICollectionViewCell, with model: JoinTeamCellModel) {
        if let cell = cell as? JoinTeamGreetingCell {
            cell.avatar.image = #imageLiteral(resourceName: "teammateF")
        }
    }
    
}
