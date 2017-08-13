//
//  ProxyCellModel.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ProxyCellModel {
    let isMyTeammate: Bool
    let userID: String
    let avatarString: String
    let name: String
    let address: String
    let time: Date? // ?
    let proxyRank: Double?
    let decisionsCoeff: Double?
    let discussionCoeff: Double?
    let frequencyCoeff: Double? // voting freq

    init(json: JSON) {
        isMyTeammate = json["IsMyTeammate"].boolValue
        userID = json["UserId"].stringValue
        avatarString = json["Avatar"].stringValue
        name = json["Name"].stringValue
        address = json["Location"].stringValue
        proxyRank = json["ProxyRank"].double
        decisionsCoeff = json["DecisionFreq"].double
        discussionCoeff = json["DiscussionFreq"].double
        frequencyCoeff = json["VotingFreq"].double
        time = nil
    }
}
