//
/* Copyright(C) 2018 Teambrella, Inc.
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

struct RiskScaleRange: Decodable {
    let left: Double
    let right: Double
    let count: Int
    let teammates: [RiskScaleTeammate]

    var minRiskTeammate: RiskScaleTeammate? {
        var risk: Double = Double.greatestFiniteMagnitude
        var teammate: RiskScaleTeammate?
        teammates.forEach { if $0.risk < risk { teammate = $0; risk = $0.risk } }
        return teammate
    }

    var maxRiskTeammate: RiskScaleTeammate? {
        var risk: Double = 0
        var teammate: RiskScaleTeammate?
        teammates.forEach { if $0.risk > risk { teammate = $0; risk = $0.risk } }
        return teammate
    }

    enum CodingKeys: String, CodingKey {
        case left = "LeftRange"
        case right = "RightRange"
        case count = "Count"
        case teammates = "TeammatesInRange"
    }

}
