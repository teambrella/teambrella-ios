//
//  SortCellDataSource.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 05.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct SortDataSource {
    var count: Int { return models.count }
    var models: [SortCellModel] = []
    
    mutating func createFakeModels() {
        models = [SortCellModel(heightCoefficient: 0.7, riskCoefficient: 0.7, isTeamAverage: false),
                  SortCellModel(heightCoefficient: 0.8, riskCoefficient: 0.8, isTeamAverage: false),
                  SortCellModel(heightCoefficient: 0.5, riskCoefficient: 0.5, isTeamAverage: false),
                  SortCellModel(heightCoefficient: 0.3, riskCoefficient: 0.3, isTeamAverage: false)]
        
    }
}
