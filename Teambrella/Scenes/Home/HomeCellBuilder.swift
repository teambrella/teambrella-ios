//
//  HomeCellBuilder.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 08.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct HomeCellBuilder {
    static func registerCells(in collectionView: UICollectionView) {
        collectionView.register(HomeSupportCell.nib,
                                forCellWithReuseIdentifier: HomeSupportCell.cellID)
        collectionView.register(HomeApplicationAcceptedCell.nib,
                                forCellWithReuseIdentifier: HomeApplicationAcceptedCell.cellID)
        collectionView.register(HomeApplicationDeniedCell.nib,
                                forCellWithReuseIdentifier: HomeApplicationDeniedCell.cellID)
        collectionView.register(HomeApplicationStatusCell.nib,
                                forCellWithReuseIdentifier: HomeApplicationStatusCell.cellID)
    }
    
    static func populate(cell: UICollectionViewCell, with model: HomeScreenModel.Card?) {
        guard let model = model else {
            populateSupport(cell: cell)
            return
        }
        
        if let cell = cell as? HomeApplicationDeniedCell {
            populate(cell: cell, with: model)
        }
        if let cell = cell as? HomeApplicationAcceptedCell {
            populate(cell: cell, with: model)
        }
        if let cell = cell as? HomeApplicationStatusCell {
            populate(cell: cell, with: model)
        }
    }
    
    static func populateSupport(cell: UICollectionViewCell) {
        guard let cell = cell as? HomeSupportCell else { return }
        
        cell.headerLabel.text = "Home.SupportCell.headerLabel".localized
        cell.centerLabel.text = "Home.SupportCell.onlineLabel".localized
        cell.bottomLabel.text = "Home.SupportCell.textLabel".localized("Frank")
        cell.button.setTitle("Home.SupportCell.chatButton".localized, for: .normal)
        cell.onlineIndicator.layer.cornerRadius = 3
    }
    
    static func populate(cell: HomeApplicationDeniedCell, with model: HomeScreenModel.Card) {
        cell.avatar.image = #imageLiteral(resourceName: "teammateF") //
        cell.headerLabel.text = "Home.ApplicationDeniedCell.headerLabel".localized
        cell.centerLabel.text = "Home.ApplicationDeniedCell.centerLabel".localized
        cell.button.setTitle("Home.ApplicationDeniedCell.viewAppButton".localized, for: .normal)
    }
    
    static func populate(cell: HomeApplicationAcceptedCell, with model: HomeScreenModel.Card) {
        cell.avatar.image = #imageLiteral(resourceName: "teammateF") //
        cell.headerLabel.text = "Home.ApplicationAcceptedCell.headerLabel".localized
        cell.centerLabel.text = "Home.ApplicationAcceptedCell.centerLabel".localized
        cell.button.setTitle("Home.ApplicationAcceptedCell.learnAboutCoverageButton".localized, for: .normal)
    }
    static func populate(cell: HomeApplicationStatusCell, with model: HomeScreenModel.Card) {
        cell.avatar.image = #imageLiteral(resourceName: "teammateF") //
        cell.headerLabel.text = "Home.ApplicationStatusCell.headerLabel".localized("Yummigum", "6 DAYS") //
        cell.titleLabel.text = "Home.ApplicationStatusCell.titleLabel".localized
        cell.centerLabel.text = "Home.ApplicationStatusCell.centerLabel".localized
        //for tests
        cell.timeLabel.text = "6 DAYS" //
        cell.bottomLabel.text = "I think it’s a great idea to let Frank in, he seems trustworthy and his application …" //
        cell.messageCountLabel.text = "4" //
    }
    
}
