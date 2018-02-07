//
//  ExtendedTeammateEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.04.17.

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

class TeammateLarge: Decodable {
    let teammateID: Int
    let lastUpdated: Int64
    var topic: TopicEntity
    var basic: BasicInfo
    var voting: VotingInfo?
    let teamPart: TeamPart?
    let object: CoveredObject
    let stats: TeammateStats
    let riskScale: RiskScaleEntity?
    var description: String {
        return "ExtendedTeammateEntity \(teammateID)"
    }

    func myProxy(set: Bool) {
        basic.isMyProxy = set
    }
    
    func update(votingResult: TeammateVotingResult) {
        topic.minutesSinceLastPost = votingResult.minutesSinceLast
        topic.unreadCount = votingResult.unreadCount
    }

    enum CodingKeys: String, CodingKey {
        case teamPart = "TeamPart"
        case teammateID = "Id"
        case lastUpdated = "LastUpdated"
        case topic = "DiscussionPart"
        case basic = "BasicPart"
        case voting = "VotingInfo"
        case object = "ObjectPart"
        case stats = "StatsPart"
        case riskScale = "RiskScalePart"
    }
    
    struct BasicInfo: Decodable {
        let id: String
        let teamID: Int

        let avatar: String
        let name: Name
        let city: String
        let facebook: String

        let isProxiedByMe: Bool
        var isMyProxy: Bool
        let role: TeammateType
        let state: TeammateState
        let gender: Gender

        let maritalStatus: MaritalStatus

        let risk: Double
        let averageRisk: Double
        let totallyPaidAmount: Double
        let coversMeAmount: Double
        let iCoverThemAmount: Double

        let dateJoined: Date?

        enum CodingKeys: String, CodingKey {
            case id = "UserId"
            case teamID = "TeamId"
            case avatar = "Avatar"
            case name = "Name"
            case city = "City"
            case facebook = "FacebookUrl"
            case isProxiedByMe = "AmIProxy"
            case isMyProxy = "IsMyProxy"
            case role = "Role"
            case state = "State"
            case maritalStatus = "MaritalStatus"
            case risk = "Risk"
            case averageRisk = "AverageRisk"
            case totallyPaidAmount = "TotallyPaidAmount"
            case coversMeAmount = "TheyCoverMeAmount"
            case iCoverThemAmount = "ICoverThemAmount"
            case gender = "Gender"
            case dateJoined = "DateJoined"
        }
    }

    struct VotingInfo: Decodable {
        let riskVoted: Double?
        let myVote: Double?
        let proxyVote: Double?

        let proxyAvatar: String?
        let proxyName: String?

        let remainingMinutes: Int

        let votersCount: Int
        let votersAvatars: [String]

        enum CodingKeys: String, CodingKey {
            case riskVoted = "RiskVoted"
            case myVote = "MyVote"
            case proxyAvatar = "ProxyAvatar"
            case proxyVote = "ProxyVote"
            case proxyName = "ProxyName"
            case remainingMinutes = "RemainedMinutes"
            case votersCount = "OtherCount"
            case votersAvatars = "OtherAvatars"
        }

    }
    
}
