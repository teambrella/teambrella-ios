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

struct NewClaimModel {
    let teamID: Int
    let incidentDate: Date
    let expenses: Double
    let message: String
    let images: [String]
    let address: String
}

struct NewChatModel {
    let teamID: Int
    let title: String
    let text: String
}

struct ChatModel {
    let discussion: JSON
    let lastRead: Int64
    let chat: [ChatEntity]
    let basicPart: JSON
    let teamPart: JSON
}
