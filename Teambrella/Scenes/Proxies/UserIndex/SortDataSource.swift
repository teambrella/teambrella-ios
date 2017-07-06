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
        models = [SortCellModel(topText: "Rating", bottomText: "High-low".uppercased()),
                  SortCellModel(topText: "Rating", bottomText: "Low-high".uppercased()),
                  SortCellModel(topText: "Alphabetical", bottomText: "A-Z"),
                  SortCellModel(topText: "Alphabetical", bottomText: "Z-A")]
    }
    
    subscript(indexPath: IndexPath) -> SortCellModel {
        return models[indexPath.row]
    }
    
}
