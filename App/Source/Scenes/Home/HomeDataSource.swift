//
//  HomeDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.07.17.

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

class HomeDataSource: SingleItemDataSource {
    var item: HomeModel?
    var cardsCount: Int {
        guard let count = item?.cards.count else { return 0 }
        
        return count // + 1
    }
    
    var isSilentUpdate = false
    var teamID: Int?
    
    var isLoading: Bool = false
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?
    
    var currency: String { return item?.teamPart.currency ?? "?" }
    var name: Name { return item?.name ?? Name.empty }
    
    func loadData() {
        guard isLoading == false else { return }
        guard let teamID = self.teamID else { return }
        
        isLoading = true
        service.dao.requestHome(teamID: teamID).observe { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            switch result {
            case .value(let value):
                if self.isSilentUpdate {
                    self.item?.cards.removeAll()
                    self.isSilentUpdate = false
                }
                self.item = value
                self.onUpdate?()
            case .error(let error):
                log("\(error)", type: .error)
            }
        }
    }
    
    func updateSilently(teamID: Int) {
        isSilentUpdate = true
        self.teamID = teamID
        loadData()
    }
    
    func cellID(for indexPath: IndexPath) -> String {
        guard let model = self[indexPath] else { return " " } //HomeSupportCell.cellID }
        
        return cellID(with: model)
    }
    
    func cellID(with cardModel: HomeCardModel) -> String {
        switch cardModel.itemType {
        case .teammate,
             .claim:
            return "HomeCollectionCell"
        case .fundWallet,
             .attachPhotos,
             .addAvatar:
            return HomeSupportCell.cellID
        default:
            return "HomeCollectionCell"
        }
    }
    
    func deleteCard(at index: Int) {
        guard let card = item?.cards.remove(at: index) else { return }
        
        service.dao.deleteCard(topicID: card.topicID).observe { [weak self] result in
            switch result {
            case .value(let homeModel):
                self?.item = homeModel
                self?.onUpdate?()
            case .error(let error):
                log("can't delete card: \(error)", type: .error)
            }
        }
       
    }
    
    subscript(indexPath: IndexPath) -> HomeCardModel? {
        guard let item = item, indexPath.row < item.cards.count else { return nil }
        
        return item.cards[indexPath.row]
    }
    
    subscript(row: Int) -> HomeCardModel? {
        guard let item = item, row < item.cards.count else { return nil }
        
        return item.cards[row]
    }
    
}
