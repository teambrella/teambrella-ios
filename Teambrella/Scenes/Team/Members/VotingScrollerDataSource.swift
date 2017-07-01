//
//  VotingScrollerDataSource.swift
//  Scroller
//
//  Created by Екатерина Рыжова on 28.06.17.
//  Copyright © 2017 Екатерина Рыжова. All rights reserved.
//

import Foundation

struct VotingScrollerDataSource {
    var count: Int { return models.count }
    var models: [VotingScrollerCellModel] = []
    
    mutating func createFakeModels() {
        models = [VotingScrollerCellModel(heightCoefficient: 0.7, riskCoefficient: 0.7, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 0.8, riskCoefficient: 0.8, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 0.5, riskCoefficient: 0.5, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 0.3, riskCoefficient: 0.3, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 0.0, riskCoefficient: 0.0, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 1.0, riskCoefficient: 1.0, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 0.9, riskCoefficient: 0.9, isTeamAverage: true),
                  VotingScrollerCellModel(heightCoefficient: 0.2, riskCoefficient: 0.2, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 0.1, riskCoefficient: 0.1, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 0.7, riskCoefficient: 0.7, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 0.8, riskCoefficient: 0.8, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 0.5, riskCoefficient: 0.5, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 0.3, riskCoefficient: 0.3, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 0.0, riskCoefficient: 0.0, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 1.0, riskCoefficient: 1.0, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 0.9, riskCoefficient: 0.9, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 0.2, riskCoefficient: 0.2, isTeamAverage: false),
                  VotingScrollerCellModel(heightCoefficient: 0.1, riskCoefficient: 0.1, isTeamAverage: false)]
        
    }
}
