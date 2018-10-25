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

struct ProxyCellModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case isMyTeammate = "IsMyTeammate"
        case userID = "UserId"
        case avatar = "Avatar"
        case name = "Name"
        case address = "Location"
        case proxyRank = "ProxyRank"
        case decisionsCoeff = "DecisionFreq"
        case discussionCoeff = "DiscussionFreq"
        case frequencyCoeff = "VotingFreq"
    }
    
    let isMyTeammate: Bool
    let userID: String
    let avatar: Avatar
    let name: String
    let address: String?
    let proxyRank: Double?
    let decisionsCoeff: Double?
    let discussionCoeff: Double?
    let frequencyCoeff: Double? // voting freq
    //    let number: Int
    //    let time: Date?
    
}
