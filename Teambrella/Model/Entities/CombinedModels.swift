//
//  CombinedModels.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TeamsModel {
    let teams: [TeamEntity]
    let invitations: [TeamEntity]
    let lastTeamID: Int?
    let userID: String
}

protocol ReportModel {
    var teamID: Int { get }
    var text: String { get }
    
    var isValid: Bool { get }
}

struct NewClaimModel: ReportModel {
    let teamID: Int
    let incidentDate: Date
    let expenses: Double
    let text: String
    let images: [String]
    let address: String
    
    var isValid: Bool { return expenses > 0
        && text.count >= 30
        && address != "" }
}

struct NewChatModel: ReportModel {
    let teamID: Int
    let title: String
    let text: String
    
    var isValid: Bool { return title != ""
        && text.count >= 30 }
}

struct ChatModel {
    let lastUpdated: Int64
    let discussion: JSON
    //let lastRead: Int64
    let chat: [ChatEntity]
    let basicPart: JSON
    let teamPart: JSON
    
    var topicID: String { return discussion["TopicId"].stringValue }
    var title: String { return basicPart["Title"].stringValue }
    var userID: String { return basicPart["UserId"].stringValue }
    var lastRead: Int64 { return discussion["LastRead"].int64Value }
}
