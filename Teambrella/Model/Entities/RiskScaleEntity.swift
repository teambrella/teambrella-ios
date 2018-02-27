//
//  RiskScaleEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 03.07.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import Foundation

class RiskScaleEntity: Decodable {
    let ranges: [RiskScaleRange]
//    let averageRisk: Double
    let coversIfMin: Double
    let coversIfOne: Double
    let coversIfMax: Double
    let myRisk: Double
    
    lazy var sortedTeammates: [RiskScaleTeammate] = {
        self.ranges.flatMap { $0.teammates }.sorted { $0.risk < $1.risk }
    }()
    
//    var averageRange: RiskScaleRange? {
//        return rangeContaining(risk: averageRisk)
//    }
    
    func rangeContaining(risk: Double) -> RiskScaleRange? {
        for range in ranges where isInRange(item: risk, min: range.left, max: range.right) {
            return range
        }
        return nil
    }
    
    func teammates(with risk: Double)
        -> (RiskScaleTeammate, RiskScaleTeammate, RiskScaleTeammate)? {
            var delta: Double = Double.greatestFiniteMagnitude
            var index = -1
            for (idx, teammate) in sortedTeammates.enumerated() {
                let newDelta = fabs(teammate.risk - risk)
                if  newDelta < delta {
                    delta = newDelta
                    index = idx
                }
            }
            guard index < sortedTeammates.count && index >= 0 && sortedTeammates.count > 2 else { return nil }

            if index > 0 {
                if index < sortedTeammates.count - 1 {
                    return (sortedTeammates[index - 1], sortedTeammates[index], sortedTeammates[index + 1])
                } else {
                    return (sortedTeammates[index - 2], sortedTeammates[index - 1], sortedTeammates[index])
                }
            } else {
                return (sortedTeammates[index], sortedTeammates[index + 1], sortedTeammates[index + 2])
            }
    }

    enum CodingKeys: String, CodingKey {
        case ranges = "Ranges"
//        case averageRisk = "AverageRisk"
        case coversIfMin = "HeCoversMeIf02"
        case coversIfOne = "HeCoversMeIf1"
        case coversIfMax = "HeCoversMeIf499"
        case myRisk = "MyRisk"
    }
    
}
