//
//  VotingScrollerCellModel.swift
//  Scroller
//
//  Created by Екатерина Рыжова on 28.06.17.
//  Copyright © 2017 Екатерина Рыжова. All rights reserved.
//

import Foundation

struct VotingScrollerCellModel {
    var heightCoefficient: Double
    var riskCoefficient: Double { return (right + left) / 2 }
    var isTeamAverage: Bool
    var right: Double
    var left: Double
}
