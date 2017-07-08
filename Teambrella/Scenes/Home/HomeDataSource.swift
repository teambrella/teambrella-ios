//
//  HomeDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

class HomeDataSource {
    var cellModels: [HomeCellModel] = []
    var count: Int { return cellModels.count }
    
    var model: HomeScreenModel?
    var cardsCount: Int { return model?.cards.count ?? 0 }
    var onUpdate: (() -> Void)?
    
    var currency: String { return model?.currency ?? "?" }
    
    func loadData(teamID: Int) {
        service.storage.requestHome(teamID: teamID,
                                    success: { [weak self] model in
                                        self?.model = model
                                        self?.onUpdate?()
        }) { error in
            print("Couldn't get data for Home screen")
        }
    }
    
    subscript(indexPath: IndexPath) -> HomeScreenModel.Card? {
        guard let model = model, indexPath.row < model.cards.count else { return nil }
        
        return model.cards[indexPath.row]
    }
    /*
     subscript(indexPath: IndexPath) -> HomeCellModel {
     return cellModels[indexPath.row]
     }
     */
    
}

extension HomeDataSource {
    func createFakeCells() {
        cellModels = [HomeSupportCellModel(),
                      HomeApplicationDeniedCellModel(),
                      HomeApplicationAcceptedCellModel(),
                      HomeApplicationStatusCellModel()]
    }
}
