//
//  TeamEntity.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 27.06.17.

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

struct TeamEntity: Decodable {
    enum CodingKeys: String, CodingKey {
        case teamID = "TeamId"
        case teammateID = "MyTeammateId"
        case teamName = "TeamName"
        case teamLogo = "TeamLogo"
        case objectName = "ObjectName"
        case objectCoverage = "ObjectCoverage"
        case unreadCount = "UnreadCount"
        case coverageType = "CoverageType"
        case teamAccessLevel = "TeamAccessLevel"
        case currency = "Currency"
        case inviteText = "InviteFriendsText"
        case myTopicID = "MyTopicId"
        case inviteCode = "InviteFriendsCode"
    }
    
    let teamID: Int
    let teammateID: Int
    let teamName: String
    let teamLogo: String
    let objectName: String?
    let objectCoverage: Coverage?
    let unreadCount: Int?
    let coverageType: CoverageType
    let teamAccessLevel: TeamAccessLevel
    let currency: String
    let inviteText: String
    let myTopicID: String
    let inviteCode: String?
    
    var currencySymbol: String {
        return ["USD": "$",
                "EUR": "€",
                "PEN": "S/.",
                "ARS": "$",
                "RUB": "₽",
                "РУБ": "₽"][currency] ?? currency
    }

    var currencyPrefix: String {
        return ["USD": "$",
                "EUR": "€",
                "PEN": "S/.",
                "ARS": "$",
                "RUB": "",
                "РУБ": ""][currency] ?? currency
    }

}

extension TeamEntity: Equatable {
    static func == (lhs: TeamEntity, rhs: TeamEntity) -> Bool {
        return lhs.teamID == rhs.teamID
    }
}
