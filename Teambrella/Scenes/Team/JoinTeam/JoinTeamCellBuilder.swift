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
        collectionView.register(JoinTeamInfoCell.nib, forCellWithReuseIdentifier: JoinTeamInfoCell.cellID)
        collectionView.register(JoinTeamPersonalCell.nib, forCellWithReuseIdentifier: JoinTeamPersonalCell.cellID)
        collectionView.register(JoinTeamItemCell.nib, forCellWithReuseIdentifier: JoinTeamItemCell.cellID)
        collectionView.register(JoinTeamMessageCell.nib, forCellWithReuseIdentifier: JoinTeamMessageCell.cellID)
        collectionView.register(JoinTeamTermsCell.nib, forCellWithReuseIdentifier: JoinTeamTermsCell.cellID)
    }
    
    static func populate(cell: UICollectionViewCell, with model: JoinTeamCellModel) {
        if let cell = cell as? JoinTeamGreetingCell {
            cell.avatar.image = #imageLiteral(resourceName: "teammateF")
        }
    }
    
}
