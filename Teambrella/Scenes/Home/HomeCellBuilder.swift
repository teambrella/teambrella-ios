//
//  HomeCellBuilder.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 08.07.17.

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
    
    static func populate(cell: UICollectionViewCell, dataSource: HomeDataSource, model: HomeScreenModel.Card?) {
        guard let model = model else {
            populateSupport(cell: cell, dataSource: dataSource)
            return
        }
        if let cell = cell as? HomeCollectionCell {
            switch model.itemType {
            case .claim:
                cell.avatarView.showImage(string: model.smallPhoto)
                cell.leftNumberView.titleLabel.text = "CLAIMED"
                cell.leftNumberView.currencyLabel.text = service.session?.currentTeam?.currencySymbol ?? "?"
                cell.titleLabel.text = model.isMine ? "Your Claim": "Claim"
                cell.rightNumberView.amountLabel.text = String(format: "%.0f", model.teamVote * 100)
                cell.rightNumberView.currencyLabel.text = "%"
            case .teammate:
                cell.avatarView.showAvatar(string: model.smallPhoto)
                cell.leftNumberView.titleLabel.text = "COVERAGE"
                cell.titleLabel.text = "New Teammate"
                cell.rightNumberView.amountLabel.text = String.formattedNumber(model.teamVote)
                cell.rightNumberView.currencyLabel.text = nil
            default:
                break
            }
            
            cell.leftNumberView.amountLabel.text = String.formattedNumber(model.amount)
            cell.leftNumberView.currencyLabel.text = dataSource.currency
            cell.rightNumberView.titleLabel.text = "TEAM VOTE"
            cell.rightNumberView.badgeLabel.text = "VOTING"
            cell.textLabel.text = model.text
            if model.unreadCount > 0 {
                cell.unreadCountView.isHidden = false
                cell.unreadCountView.text = String(model.unreadCount)
            } else {
                cell.unreadCountView.isHidden = true
            }
           
            if let date = model.itemDate {
                cell.subtitleLabel.text = DateProcessor().stringInterval(from: date)
            }
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
    
    static func populateSupport(cell: UICollectionViewCell, dataSource: HomeDataSource) {
        guard let cell = cell as? HomeSupportCell else { return }
        
        cell.headerLabel.text = "Home.SupportCell.headerLabel".localized
        cell.centerLabel.text = "Home.SupportCell.onlineLabel".localized
        cell.bottomLabel.text = "Home.SupportCell.textLabel".localized(dataSource.name)
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
        cell.bottomLabel.text = "I think it’s a great idea to let Frank in, he seems trustworthy and his application …"
        cell.messageCountLabel.text = "4" //
    }
    
}
