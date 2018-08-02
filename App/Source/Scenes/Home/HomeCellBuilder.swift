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
        collectionView.register(HomeFundCell.nib,
                                forCellWithReuseIdentifier: HomeFundCell.cellID)
//        collectionView.register(HomeSupportCell.nib,
//                                forCellWithReuseIdentifier: HomeSupportCell.cellID)
        collectionView.register(HomeApplicationAcceptedCell.nib,
                                forCellWithReuseIdentifier: HomeApplicationAcceptedCell.cellID)
        collectionView.register(HomeApplicationDeniedCell.nib,
                                forCellWithReuseIdentifier: HomeApplicationDeniedCell.cellID)
        collectionView.register(HomeApplicationStatusCell.nib,
                                forCellWithReuseIdentifier: HomeApplicationStatusCell.cellID)
    }
    
    static func populate(cell: UICollectionViewCell, dataSource: HomeDataSource, model: HomeCardModel?) {
        guard let model = model else {
            populateFundWallet(cell: cell, dataSource: dataSource)
//            populateSupport(cell: cell, dataSource: dataSource)
            return
        }
        
        switch cell {
        case let cell as HomeCollectionCell:
            populateHome(cell: cell, model: model)
        case let cell as HomeApplicationDeniedCell:
            populate(cell: cell, with: model)
        case let cell as HomeApplicationAcceptedCell:
            populate(cell: cell, with: model)
        case let cell as HomeApplicationStatusCell:
            populate(cell: cell, with: model)
        default:
            break
        }
    }
    
    static func populateHome(cell: HomeCollectionCell, model: HomeCardModel) {
        let session = service.session
        
        switch model.itemType {
        case .claim:
            setupClaimCell(cell: cell, model: model)
        case .teammate:
            setupTeammateCell(cell: cell, model: model)
        default:
            break
        }
        
        cell.leftNumberView.amountLabel.text = model.amount.formatted
        cell.leftNumberView.currencyLabel.text = session?.currentTeam?.currency ?? ""
        cell.rightNumberView.titleLabel.text = "Team.Home.Card.teamVote".localized
        cell.rightNumberView.badgeLabel.text = "Team.Home.Card.voting".localized
        cell.textLabel.text = model.text.sane
        if model.unreadCount > 0 {
            cell.unreadCountView.isHidden = false
            cell.unreadCountView.text = String(model.unreadCount)
        } else {
            cell.unreadCountView.isHidden = true
        }
        cell.rightNumberView.isBadgeVisible = model.isVoting
    }
    
    static func populateSupport(cell: UICollectionViewCell, dataSource: HomeDataSource) {
        guard let cell = cell as? HomeSupportCell else { return }
        
            cell.headerLabel.text = "Home.SupportCell.headerLabel".localized
            cell.centerLabel.text = "Home.SupportCell.onlineLabel".localized
            cell.bottomLabel.text = "Home.SupportCell.textLabel".localized(dataSource.name.first)
            cell.button.setTitle("Home.SupportCell.chatButton".localized, for: .normal)
            cell.onlineIndicator.layer.cornerRadius = 3
    }
    
    static func populateFundWallet(cell: UICollectionViewCell, dataSource: HomeDataSource) {
        guard let cell = cell as? HomeFundCell else { return }
        
        cell.headerLabel.text = "Home.FundCell.headerLabel".localized
        cell.centerLabel.textAlignment = .center
        cell.centerLabel.text = "Home.FundCell.textLabel".localized(dataSource.name.first)
        cell.button.setTitle("Home.FundCell.fundTitle".localized, for: .normal)
    }
    
    static func populate(cell: HomeApplicationDeniedCell, with model: HomeCardModel) {
        cell.avatar.image = #imageLiteral(resourceName: "teammateF") //
        cell.headerLabel.text = "Home.ApplicationDeniedCell.headerLabel".localized
        cell.centerLabel.text = "Home.ApplicationDeniedCell.centerLabel".localized
        cell.button.setTitle("Home.ApplicationDeniedCell.viewAppButton".localized, for: .normal)
    }
    
    static func populate(cell: HomeApplicationAcceptedCell, with model: HomeCardModel) {
        cell.avatar.image = #imageLiteral(resourceName: "teammateF") //
        cell.headerLabel.text = "Home.ApplicationAcceptedCell.headerLabel".localized
        cell.centerLabel.text = "Home.ApplicationAcceptedCell.centerLabel".localized
        cell.button.setTitle("Home.ApplicationAcceptedCell.learnAboutCoverageButton".localized, for: .normal)
    }
    static func populate(cell: HomeApplicationStatusCell, with model: HomeCardModel) {
        cell.avatar.image = #imageLiteral(resourceName: "teammateF") //
        cell.headerLabel.text = "Home.ApplicationStatusCell.headerLabel".localized("Yummigum", "6 DAYS") //
        cell.titleLabel.text = "Home.ApplicationStatusCell.titleLabel".localized
        cell.centerLabel.text = "Home.ApplicationStatusCell.centerLabel".localized
        //for tests
        cell.timeLabel.text = "6 DAYS" //
        cell.bottomLabel.text = "I think it’s a great idea to let Frank in, he seems trustworthy and his application …"
        cell.messageCountLabel.text = "4" //
    }
    
    static private func setupClaimCell(cell: HomeCollectionCell, model: HomeCardModel) {
        let session = service.session
        cell.titleLabel.text = model.itemName
        cell.ownerAvatarView.isHidden = false
        cell.ownerAvatarView.kf.setImage(with: URL(string: URLBuilder().avatarURLstring(for: model.userAvatar)))
        cell.subtitleLabel.text = model.userName.entire.uppercased()
        cell.avatarView.show(model.smallPhoto)
        cell.avatarView.roundCorners(.allCorners, radius: 3)
        cell.leftNumberView.titleLabel.text = "Team.Home.Card.claimed".localized
        cell.leftNumberView.currencyLabel.text = session?.currentTeam?.currencySymbol ?? ""
        cell.leftNumberView.isCurrencyVisible = true
        cell.leftNumberView.isPercentVisible = false
        let amountText: String = model.teamVote.map { String(format: "%.0f", $0 * 100) } ?? "..."
        cell.rightNumberView.amountLabel.text = amountText
        cell.rightNumberView.isBadgeVisible = model.isVoting
        cell.rightNumberView.isPercentVisible = model.teamVote != nil
    }
    
    static private func setupTeammateCell(cell: HomeCollectionCell, model: HomeCardModel) {
        cell.titleLabel.text = model.userName.entire
        cell.subtitleLabel.text = model.itemName.uppercased()
        cell.ownerAvatarView.isHidden = true
        cell.avatarView.show(model.smallPhoto)
        cell.avatarView.roundCorners(.allCorners, radius: cell.avatarView.bounds.width / 2)
        cell.leftNumberView.titleLabel.text = "Team.Home.Card.coverage".localized
        cell.leftNumberView.isCurrencyVisible = true
        cell.leftNumberView.isPercentVisible = false
        let amountText: String = model.teamVote.map { String(format: "%.1f", $0) } ?? "..."
        cell.rightNumberView.amountLabel.text = amountText
        cell.rightNumberView.isBadgeVisible = model.isVoting
        cell.rightNumberView.isCurrencyVisible = false
        cell.rightNumberView.isPercentVisible = false
    }
    
}
