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
        service.session.currentTeam
        models = []
    }
    
    subscript(indexPath: IndexPath) -> ChooseYourTeamCellModel {
        return models[indexPath.row]
    }
    
}

/*
 struct TeamEntity {
 private var json: JSON
 
 init(json: JSON) {
 self.json = json
 }
 
 var teamID: Int { return json["TeamId"].intValue }
 var teamType: Int { return json["TeamType"].intValue }
 var teamName: String { return json["TeamName"].stringValue }
 var objectName: String? { return json["ObjectName"].stringValue }
 var objectCoverage: Double? { return json["ObjectCoverage"].doubleValue }
 var unreadCount: Int? { return json["UnreadCount"].intValue }
 var teamCoverage: Double? { return json["TeamCoverage"].doubleValue }
 
 var isInvitation: Bool { return teamCoverage != nil }
 
 static func team(with json: JSON) -> TeamEntity {
 return TeamEntity(json: json)
 }
 
 static func teams(with json: JSON) -> [TeamEntity] {
 return json.arrayValue.map { self.team(with: $0) }
 }
 }

 */
