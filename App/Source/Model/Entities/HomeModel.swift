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
        case claimLimit       = "ClaimLimit"
    }
    
    var cards: [HomeCardModel]
    let teamPart: TeamPart
    let userID: String
    let facebookID: String?
    let name: Name
    let avatar: Avatar
    let unreadCount: Int
    let balance: Ether
    let coverage: Coverage
    let objectName: Name
    let smallPhoto: Photo
    let haveVotingClaims: Bool
    let claimLimit: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cards = try container.decode([HomeCardModel].self, forKey: .cards)
        teamPart = try container.decode(TeamPart.self, forKey: .teamPart)
        userID = try container.decode(String.self, forKey: .userID)
        let facebookIDString = try? container.decodeIfPresent(String.self, forKey: .facebookID)
        let facebookIDInt = try? container.decodeIfPresent(Int.self, forKey: .facebookID)
        facebookID = facebookIDString ?? facebookIDInt.map { String(describing: $0) }
        name = try container.decode(Name.self, forKey: .name)
        avatar = try container.decode(Avatar.self, forKey: .avatar)
        unreadCount = try container.decode(Int.self, forKey: .unreadCount)
        balance = try container.decode(Ether.self, forKey: .balance)
        coverage = try container.decode(Coverage.self, forKey: .coverage)
        objectName = try container.decode(Name.self, forKey: .objectName)
        smallPhoto = try container.decode(Photo.self, forKey: .smallPhoto)
        haveVotingClaims = try container.decode(Bool.self, forKey: .haveVotingClaims)
        claimLimit = try container.decode(Int.self, forKey: .claimLimit)
    }

}
