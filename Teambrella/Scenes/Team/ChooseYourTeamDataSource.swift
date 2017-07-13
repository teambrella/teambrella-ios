//
//  ChooseYourTeamDataSource.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 13.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct ChooseYourTeamDataSource {
    var count: Int { return models.count }
    var models: [ChooseYourTeamCellModel] = []
    
    mutating func createFakeModels() {
        models = [ChooseYourTeamCellModel(),
                  ChooseYourTeamCellModel(topText: "Proxy.SortVC.Cell.Rating".localized,
                                bottomText: "Proxy.SortVC.Cell.Rating.LowHigh".localized)]
    }
    
    subscript(indexPath: IndexPath) -> ChooseYourTeamCellModel {
        return models[indexPath.row]
    }
    
}
