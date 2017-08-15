//
//  ProxyCellModel.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.

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
