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
    
    mutating func createModels() {
        let model = service.session.teams
        for card in model {
            if let inc = card.unreadCount, let item = card.objectName, let cvg = card.teamCoverage {
                models.append(ChooseYourTeamCellModel(teamIcon: #imageLiteral(resourceName: "yummy"),
                                                      incomingCount: inc,
                                                      teamName: card.teamName,
                                                      itemName: item,
                                                      coverage: Int(cvg)))
            }
        }
    }
    
    subscript(indexPath: IndexPath) -> ChooseYourTeamCellModel {
        return models[indexPath.row]
    }
    
}
