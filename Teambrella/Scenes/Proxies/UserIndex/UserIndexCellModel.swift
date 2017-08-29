//
//  UserIndexCellModel.swift
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

struct UserIndexCellModel {
    let userID: String
    let avatarString: String
    let proxyRank: Double
    let discussionFreq: Double?
    let decisionFreq: Double?
    let location: String
    let position: Int?
    let name: String
    let votingFreq: Int?
    
    init(json: JSON) {
        userID = json["UserId"].stringValue
        avatarString = json["Avatar"].stringValue
        proxyRank = json["Commission"].doubleValue
        discussionFreq = json["DiscussionFreq"].double
        decisionFreq = json["DecisionFreq"].double
        location = json["Location"].stringValue
        position = json["Position"].int
        name = json["Name"].stringValue
        votingFreq = json["VotingFreq"].int
    }
}
