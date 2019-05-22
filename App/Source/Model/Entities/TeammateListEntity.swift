//
//  TeammateEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 05.04.17.

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

class TeammateListEntity: Decodable {
    let id: Int

    let claimLimit: Decimal
    let claimsCount: Int
    let isJoining: Bool
    let isVoting: Bool
    let model: String
    let name: Name
    let risk: Double?
    let riskVoted: Double?
    let totallyPaid: Double
    let coversMe: Double
    let hasUnread: Bool
    let userID: String
    let year: Year?
    let avatar: Avatar
    let minutesRemaining: Int

    init() {
        id = 0
        claimLimit = 0
        claimsCount = 0
        isJoining = false
        isVoting = false
        model = ""
        name = Name.empty
        risk = nil
        riskVoted = nil
        totallyPaid = 0
        coversMe = 0
        hasUnread = false
        userID = ""
        year = nil
        avatar = .none
        minutesRemaining = 0
    }

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case claimLimit = "ClaimLimit"
        case claimsCount = "ClaimsCount"
        case isJoining = "IsJoining"
        case isVoting = "IsVoting"
        case model = "Model"
        case name = "Name"
        case risk = "Risk"
        case riskVoted = "RiskVoted"
        case totallyPaid = "TotallyPaid"
        case coversMe = "CoversMe"
        case hasUnread = "Unread"
        case userID = "UserId"
        case year = "Year"
        case avatar = "Avatar"
        case minutesRemaining = "VotingEndsIn"
    }
    
}
