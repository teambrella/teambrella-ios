//
//  TeammateEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 05.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TeammateEntity: Teammate {
    var ver: Int64
    let id: String

    let claimLimit: Int
    let claimsCount: Int
    let isJoining: Bool
    let isVoting: Bool
    let model: String
    let name: String
    let risk: Double
    let riskVoted: Double
    let totallyPaid: Double
    let hasUnread: Bool
    let userID: String
    let year: Int
    
    var description: String {
        return "Teammate \(name) id: \(id); ver: \(ver)"
    }
    
    init(json: JSON) {
        claimLimit = json["ClaimLimit"].intValue
        claimsCount = json["ClaimsCount"].intValue
        id = json["Id"].stringValue
        isJoining = json["IsJoining"].boolValue
        isVoting = json["IsVoting"].boolValue
        model = json["Model"].stringValue
        name = json["Name"].stringValue
        risk = json["Risk"].doubleValue
        riskVoted = json["RiskVoted"].doubleValue
        totallyPaid = json["TotallyPaid"].doubleValue
        hasUnread = json["Unread"].boolValue
        userID = json["UserId"].stringValue
        ver = json["Ver"].int64Value
        year = json["Year"].intValue
    }
    
}

struct TeammateEntityFactory {
    static func teammates(from json: JSON) -> [TeammateEntity]? {
        guard let teammates = json["Teammates"].array else { return nil }
        
        return teammates.map { TeammateEntity(json: $0) }
    }
    
    static func teammate(from json: JSON) -> TeammateEntity? {
        return TeammateEntity(json: json)
    }
}
