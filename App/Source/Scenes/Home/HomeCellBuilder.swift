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
    
    static func populate(cell: UICollectionViewCell, dataSource: HomeDataSource, model: HomeCardModel?) {
        guard let model = model else {
            return
        }

        if model.itemType.isServiceType {
            populateServiceCell(cell: cell, model: model)
        } else {
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

        let amount = model.amount ?? Fiat(0)
        cell.leftNumberView.amountLabel.text = amount.formatted
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
        cell.rightNumberView.isBadgeVisible = model.isVoting ?? false
    }
    
    static func populateServiceCell(cell: UICollectionViewCell, model: HomeCardModel) {
        guard let cell = cell as? HomeSupportCell else { return }
        
        cell.button.setTitle("", for: .normal)
        cell.imageView.show(model.smallPhoto)
        cell.headerLabel.text = model.chatTitle
        cell.centerLabel.text = model.subtitle
        cell.bottomLabel.text = model.text.sane
        if let saneText = model.actionText {
        cell.button.setTitle(saneText.sane, for: .normal)
        }
        cell.onlineIndicator.isHidden = true
    }
    
    static func populateSupport(cell: UICollectionViewCell, dataSource: HomeDataSource) {
        guard let cell = cell as? HomeSupportCell else { return }
        
        cell.headerLabel.text = "Home.SupportCell.headerLabel".localized
        cell.centerLabel.text = "Home.SupportCell.onlineLabel".localized
        cell.bottomLabel.text = "Home.SupportCell.textLabel".localized(dataSource.name.first)
        cell.button.setTitle("Home.SupportCell.chatButton".localized, for: .normal)
        cell.onlineIndicator.layer.cornerRadius = 3
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
        if let avatar = model.userAvatar {
        cell.ownerAvatarView.show(avatar)
        }
        cell.subtitleLabel.text = model.userName?.entire.uppercased()
        cell.avatarView.show(model.smallPhoto)
        cell.avatarView.roundCorners(.allCorners, radius: 3)
        cell.leftNumberView.titleLabel.text = "Team.Home.Card.claimed".localized
        cell.leftNumberView.currencyLabel.text = session?.currentTeam?.currencySymbol ?? ""
        cell.leftNumberView.isCurrencyVisible = true
        cell.leftNumberView.isPercentVisible = false
        let vote = model.teamVote ?? 0
        cell.rightNumberView.amountLabel.text = vote * 100 != 0
            ? String(format: "%.0f", vote * 100)
            : "..."
        cell.rightNumberView.isBadgeVisible = model.isVoting ?? false
        cell.rightNumberView.isPercentVisible = model.teamVote != 0
    }
    
    static private func setupTeammateCell(cell: HomeCollectionCell, model: HomeCardModel) {
        cell.titleLabel.text = model.userName?.entire
        let itemName = model.itemName ?? ""
        cell.subtitleLabel.text = itemName.uppercased()
        cell.ownerAvatarView.isHidden = true
        if let avatar = model.userAvatar {
        cell.avatarView.show(avatar)
        }
        cell.avatarView.roundCorners(.allCorners, radius: cell.avatarView.bounds.width / 2)
        cell.leftNumberView.titleLabel.text = "Team.Home.Card.coverage".localized
        cell.leftNumberView.isCurrencyVisible = true
        cell.leftNumberView.isPercentVisible = false
        let vote = model.teamVote ?? 0
        cell.rightNumberView.amountLabel.text = vote != 0
            ? String(format: "%.1f", vote)
            : "..."
        cell.rightNumberView.isBadgeVisible = model.isVoting ?? false
        cell.rightNumberView.isCurrencyVisible = false
        cell.rightNumberView.isPercentVisible = false
    }
    
}
