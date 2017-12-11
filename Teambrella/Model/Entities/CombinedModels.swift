//
//  CombinedModels.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 23.08.17.
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
    
    var isValid: Bool { return expenses > 0 && text.count >= 30 && address != "" }
}

struct NewChatModel: ReportModel {
    let teamID: Int
    let title: String
    let text: String
    
    var isValid: Bool { return title != "" && text.count >= 30 }
}

struct ChatModel {
    let lastUpdated: Int64
    let discussion: JSON
    //let lastRead: Int64
    let chat: [ChatEntity]
    let basicPart: JSON
    let teamPart: JSON
    let votingPart: JSON
    
    // Basic Part
    var year: Int { return basicPart["Year"].intValue }
    var userID: String { return basicPart["UserId"].stringValue }
    var model: String { return basicPart["Model"].stringValue }
    var name: String { return basicPart["Name"].stringValue }
    var smallPhoto: String { return basicPart["SmallPhoto"].stringValue }
    var avatar: String { return basicPart["Avatar"].stringValue }
    
    var title: String { return basicPart["Title"].stringValue }

    // Voting Part
    var remainingMinutes: Int { return votingPart["RemainedMinutes"].intValue }
    var proxyName: String? { return votingPart["ProxyName"].string }
    var vote: Double? { return votingPart["MyVote"].double }
    var riskVoted: Double? { return votingPart["RiskVoted"].double }
    
    //TeamPart
    var coverageType: CoverageType? { return teamPart["CoverageType"].int.flatMap { CoverageType(rawValue: $0) } }
    var currency: String { return teamPart["Currency"].stringValue }
    var teamAccessLevel: TeamAccessLevel {
        return TeamAccessLevel(rawValue: teamPart["TeamAccessLevel"].intValue) ?? .noAccess
    }
    
    // Discussion Part
    var topicID: String { return discussion["TopicId"].stringValue }
    var lastRead: Int64 { return discussion["LastRead"].int64Value }
}
