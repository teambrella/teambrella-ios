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
        models = [SortCellModel(topText: "Proxy.SortVC.Cell.Rating".localized, bottomText: "Proxy.SortVC.Cell.Rating.HighLow".localized),
                  SortCellModel(topText: "Proxy.SortVC.Cell.Rating".localized, bottomText: "Proxy.SortVC.Cell.Rating.LowHigh".localized),
                  SortCellModel(topText: "Proxy.SortVC.Cell.Alphabetical".localized, bottomText: "Proxy.SortVC.Cell.Alphabetical.AZ".localized),
                  SortCellModel(topText: "Proxy.SortVC.Cell.Alphabetical".localized, bottomText: "Proxy.SortVC.Cell.Alphabetical.ZA".localized)]
    }
    
    subscript(indexPath: IndexPath) -> SortCellModel {
        return models[indexPath.row]
    }
    
}
