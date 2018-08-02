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

class HomeDataSource {
    var model: HomeModel?
    var cardsCount: Int {
        guard let count = model?.cards.count else { return 0 }
        
        return count //+ 1
    }
    
    var isSilentUpdate = false
    
    var onUpdate: (() -> Void)?
    
    var currency: String { return model?.teamPart.currency ?? "?" }
    var name: Name { return model?.name ?? Name.empty }
    
    func loadData(teamID: Int) {
        service.dao.requestHome(teamID: teamID).observe { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .value(let value):
                if self.isSilentUpdate {
                    self.model?.cards.removeAll()
                    self.isSilentUpdate = false
                }
                self.model = value
                self.onUpdate?()
            case .error(let error):
                log("\(error)", type: .error)
            }
        }
    }
    
    func updateSilently(teamID: Int) {
        isSilentUpdate = true
        loadData(teamID: teamID)
    }
    
    func cellID(for indexPath: IndexPath) -> String {
        guard let model = self[indexPath] else { return " " } //HomeFundCell.cellID } //HomeSupportCell.cellID }
        
        return cellID(with: model)
    }
    
    func cellID(with cardModel: HomeCardModel) -> String {
        switch cardModel.itemType {
        case .teammate, .claim:
            return "HomeCollectionCell"
        default:
            return "HomeCollectionCell"
        }
    }
    
    func deleteCard(at index: Int) {
        guard let card = model?.cards.remove(at: index) else { return }
        
        service.dao.deleteCard(topicID: card.topicID).observe { [weak self] result in
            switch result {
            case .value(let homeModel):
                self?.model = homeModel
                self?.onUpdate?()
            case .error(let error):
                log("can't delete card: \(error)", type: .error)
            }
        }
       
    }
    
    subscript(indexPath: IndexPath) -> HomeCardModel? {
        guard let model = model, indexPath.row < model.cards.count else { return nil }
        
        return model.cards[indexPath.row]
    }
    
}
