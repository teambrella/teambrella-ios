//
//  VotingScrollerDataSource.swift
//  Scroller
//
//  Created by Екатерина Рыжова on 28.06.17.
//  Copyright © 2017 Екатерина Рыжова. All rights reserved.
//

import Foundation
import ThoraxMath

struct VotingScrollerDataSource {
    var count: Int { return models.count }
    var models: [VotingScrollerCellModel] = []
    
    var onUpdate: (() -> Void)?
    
    mutating func createModels(with riskScale: RiskScaleEntity, averageRisk: Double) {
        let max: Double = Double(riskScale.ranges.map { $0.count }.max() ?? 0)
        var models: [VotingScrollerCellModel] = []
        for range in riskScale.ranges {
            let isTeamAverage = isInRange(item: averageRisk, min: range.left, max: range.right)
            let model = VotingScrollerCellModel(heightCoefficient: Double(range.count) / max,
                                                isTeamAverage: isTeamAverage,
                                                right: range.right,
                                                left: range.left)
            models.append(model)
        }
        self.models = models
        onUpdate?()
    }
}
