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
import SwiftyJSON

struct RiskScaleEntity {
    struct Teammate {
        let id: String
        let avatar: String
        let risk: Double
        
        init(json: JSON) {
            id = json["UserId"].stringValue
            avatar = json["Avatar"].stringValue
            risk = json["Risk"].doubleValue
        }
    }
    
    struct Range {
        let left: Double
        let right: Double
        let count: Int
        let teammates: [Teammate]
        
        var minRiskTeammate: Teammate? {
            var risk: Double = Double.greatestFiniteMagnitude
            var teammate: Teammate?
            teammates.forEach { if $0.risk < risk { teammate = $0; risk = $0.risk } }
            return teammate
        }
        
        var maxRiskTeammate: Teammate? {
            var risk: Double = 0
            var teammate: Teammate?
            teammates.forEach { if $0.risk > risk { teammate = $0; risk = $0.risk } }
            return teammate
        }
        
        init(json: JSON) {
            left = json["LeftRange"].doubleValue
            right = json["RightRange"].doubleValue
            count = json["Count"].intValue
            teammates = json["TeammatesInRange"].arrayValue.flatMap { Teammate(json: $0) }
        }
    }
    
    let ranges: [Range]
    let averageRisk: Double
    let coversIfMin: Double
    let coversIf1: Double
    let coversIfMax: Double
    let myRisk: Double
    
    lazy var sortedTeammates: [Teammate] = { self.ranges.flatMap { $0.teammates }.sorted { $0.risk < $1.risk } }()
    
    var averageRange: Range? {
       return rangeContaining(risk: averageRisk)
    }
    
    func rangeContaining(risk: Double) -> Range? {
        for range in ranges where isInRange(item: risk, min: range.left, max: range.right) {
            return range
        }
        return nil
    }
    
    mutating func teammates(with risk: Double) -> (Teammate, Teammate, Teammate)? {
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
    
    init?(json: JSON) {
        guard json.exists() else { return nil }
        
        ranges = json["Ranges"].arrayValue.flatMap { Range(json: $0) }
        averageRisk = json["AverageRisk"].doubleValue
        coversIfMin = json["HeCoversMeIf02"].doubleValue
        coversIf1 = json["HeCoversMeIf1"].doubleValue
        coversIfMax = json["HeCoversMeIf499"].doubleValue
        myRisk = json["MyRisk"].doubleValue
    }
    
}
