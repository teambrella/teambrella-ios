//
//  TeamEntity.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 27.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

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
