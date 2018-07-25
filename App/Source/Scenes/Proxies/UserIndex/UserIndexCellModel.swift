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

struct UserIndexCellModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case userID = "UserId"
        case avatarString = "Avatar"
        case name = "Name"
        case location = "Location"
        case proxyRank = "ProxyRank"
        case decisionFreq = "DecisionFreq"
        case discussionFreq = "DiscussionFreq"
        case votingFreq = "VotingFreq"
        case position = "Position"
        case teams = "Teams"
    }
    
    let userID: String
    let avatarString: String
    let proxyRank: Double
    let discussionFreq: Double?
    let decisionFreq: Double?
    let location: String
    let position: Int?
    let name: String
    let votingFreq: Int?
    let teams: [Int]
    
}
