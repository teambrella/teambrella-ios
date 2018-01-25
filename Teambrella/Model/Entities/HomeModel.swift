//
//  HomeModel.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.07.17.

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

struct HomeModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case cards            = "Cards"
        case userID           = "UserId"
        case facebookID       = "FBName"
        case name             = "Name"
        case avatar           = "Avatar"
        case unreadCount      = "UnreadCount"
        case balance          = "CryptoBalance"
        case coverage         = "Coverage"
        case objectName       = "ObjectName"
        case smallPhoto       = "SmallPhoto"
        case haveVotingClaims = "HaveVotingClaims"
        case teamPart         = "TeamPart"
    }
    
    var cards: [HomeCardModel]
    let teamPart: TeamPart
    let userID: String
    let facebookID: UInt64?
    let name: Name
    let avatar: String
    let unreadCount: Int
    let balance: Double
    let coverage: Double
    let objectName: String
    let smallPhoto: String
    let haveVotingClaims: Bool
    
}
