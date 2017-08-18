//
//  TeamEntity.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 27.06.17.

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

struct TeamEntity {
    private var json: JSON
    
    init(json: JSON) {
        self.json = json
    }
    
    var teamID: Int { return json["TeamId"].intValue }
    var teamType: Int { return json["TeamType"].intValue }
    var teamName: String { return json["TeamName"].stringValue }
    var teamLogo: String { return json["TeamLogo"].stringValue }
    var objectName: String? { return json["ObjectName"].stringValue }
    var objectCoverage: Double? { return json["ObjectCoverage"].doubleValue }
    var unreadCount: Int? { return json["UnreadCount"].intValue }
    var teamCoverage: Double? { return json["TeamCoverage"].doubleValue }
    var coverageType: CoverageType { return CoverageType(rawValue: json["CoverageType"].intValue) ?? .other }
    var teamAccessLevel: TeamAccessLevel {
        return TeamAccessLevel(rawValue: json["TeamAccessLevel"].intValue) ?? .noAccess
    }
    var currency: String { return json["Currency"].stringValue }
    
    var isInvitation: Bool { return teamCoverage != nil }
    
    static func team(with json: JSON) -> TeamEntity {
        return TeamEntity(json: json)
    }
    
    static func teams(with json: JSON) -> [TeamEntity] {
        return json.arrayValue.map { self.team(with: $0) }
    }
}

extension TeamEntity: Equatable {
    static func == (lhs: TeamEntity, rhs: TeamEntity) -> Bool {
        return lhs.teamID == rhs.teamID
    }
}
