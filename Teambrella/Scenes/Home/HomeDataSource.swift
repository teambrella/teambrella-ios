//
//  HomeDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

class HomeDataSource {
    var model: HomeScreenModel?
    var cardsCount: Int {
        guard let count = model?.cards.count else { return 0 }
        
        return count + 1
    }
    
    var onUpdate: (() -> Void)?
    
    var currency: String { return model?.currency ?? "?" }
    var name: String { return model?.name.components(separatedBy: " ").first ?? "" }
    
    func loadData(teamID: Int) {
        service.storage.requestHome(teamID: teamID,
                                    success: { [weak self] model in
                                        self?.model = model
                                        self?.onUpdate?()
        }) { error in
            print("Couldn't get data for Home screen")
        }
    }
    
    func cellID(for indexPath: IndexPath) -> String {
        guard let model = self[indexPath] else { return HomeSupportCell.cellID }
        
        return cellID(with: model)
    }
    
    func cellID(with cardModel: HomeScreenModel.Card) -> String {
        switch cardModel.itemType {
        case .teammate, .claim:
            return "HomeCollectionCell"
        default:
            return "HomeCollectionCell"
        }
    }
    
    subscript(indexPath: IndexPath) -> HomeScreenModel.Card? {
        guard let model = model, indexPath.row < model.cards.count else { return nil }
        
        return model.cards[indexPath.row]
    }
    
}
