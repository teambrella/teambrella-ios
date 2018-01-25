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
import SwiftyJSON

class TeammateLarge {
    let id: String
    let teammateID: Int
    let ver: Int64
    
    let lastUpdated: Int64
    
    var topic: Topic
    var basic: BasicInfo
    var voting: VotingInfo?
    let teamPart: TeamPart?
    let object: CoveredObject
    let stats: TeammateStats
    let riskScale: RiskScaleEntity?

    var description: String {
        return "ExtendedTeammateEntity \(id)"
    }
    
    init(json: JSON) {

        teamPart = TeamPart(json: json["TeamPart"])

        id = json["UserId"].stringValue
        teammateID = json["Id"].intValue
        ver = json["Ver"].int64Value
        lastUpdated = json["LastUpdated"].int64Value
        topic = TopicFactory.topic(with: json["DiscussionPart"])
        basic = BasicInfo(json: json["BasicPart"])
        voting = VotingInfo(json: json["VotingPart"])
        object = CoveredObject(json: json["ObjectPart"])
        stats = TeammateStats(json: json["StatsPart"])
        riskScale = RiskScaleEntity(json: json["RiskScalePart"])
    }
    
    func myProxy(set: Bool) {
        basic.isMyProxy = set
    }
    
    func update(votingResult: TeammateVotingResult) {
        topic.minutesSinceLastPost = votingResult.minutesSinceLast
        topic.unreadCount = votingResult.unreadCount
    }

    struct BasicInfo {
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

        init(json: JSON) {
            id = json["UserId"].stringValue
            teamID = json["TeamId"].intValue
            avatar = json["Avatar"].stringValue
            name = Name(fullName: json["Name"].stringValue)
            city = json["City"].stringValue
            facebook = json["FacebookUrl"].stringValue
            isProxiedByMe = json["AmIProxy"].boolValue
            isMyProxy = json["IsMyProxy"].boolValue
            role = TeammateType(rawValue: json["Role"].intValue) ?? .regular
            state = TeammateState(rawValue: json["State"].intValue) ?? .joinVoting
            maritalStatus = MaritalStatus(rawValue: json["MaritalStatus"].intValue) ?? .unknown
            risk = json["Risk"].doubleValue
            averageRisk = json["AverageRisk"].doubleValue
            totallyPaidAmount = json["TotallyPaidAmount"].doubleValue
            coversMeAmount = json["TheyCoverMeAmount"].doubleValue
            iCoverThemAmount = json["ICoverThemAmount"].doubleValue
            gender = Gender.fromServer(integer: json["Gender"].intValue)
            dateJoined = Formatter.teambrella.date(from: json["DateJoined"].stringValue)
        }
    }

    struct VotingInfo {
        let riskVoted: Double?
        let myVote: Double?
        //let proxyVote: Double?

        let proxyAvatar: String?
        let proxyName: String?

        let remainingMinutes: Int

        let votersCount: Int
        let votersAvatars: [String]

        let otherCount: Int

        init?(json: JSON) {
            guard json.dictionary != nil else { return nil }

            riskVoted = json["RiskVoted"].double
            myVote = json["MyVote"].double
            //proxyVote = json["ProxyVote"].double
            proxyAvatar = json["ProxyAvatar"].string
            proxyName = json["ProxyName"].string
            remainingMinutes = json["RemainedMinutes"].intValue
            votersCount = json["OtherCount"].intValue
            votersAvatars = json["OtherAvatars"].arrayObject as? [String] ?? []
            otherCount = json["OtherCount"].intValue
        }

    }
    
}
